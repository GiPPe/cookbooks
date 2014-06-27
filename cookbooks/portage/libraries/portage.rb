module Gentoo
  module Portage
    module PackageConf

      # Creates or deletes per package portage attributes. Returns true if it
      # changes (sets or deletes) something.
      # * action == :create || action == :delete
      # * conf_type =~ /\A(use|keywords|mask|unmask)\Z/
      def manage_package_conf(action, conf_type, new_resource)
        conf_file = package_conf_file(conf_type, new_resource.name)
        conf_dir = File.dirname(conf_file)
        unless ::File.directory?(conf_dir)
          run("/usr/bin/sudo -H /bin/rm -rf #{conf_dir}")
          run("/usr/bin/sudo -H /bin/mkdir -p #{conf_dir}")
        end
        updated = case action
        when :create
          flags =
            case conf_type
            when "use"
              new_resource.use
            when "keywords"
              new_resource.keywords
            else
              nil
            end
          create_package_conf_file(conf_file, new_resource.package, flags)
        when :delete
          delete_package_conf_file(conf_file)
        else
          raise Chef::Exceptions::Package, "Unknown action :#{action}."
        end
        new_resource.updated_by_last_action(updated)
        begin
          package_resource = run_context.resource_collection.find(package: new_resource.package)
          new_resource.notifies(:upgrade, package_resource, :immediately) if updated
        rescue Chef::Exceptions::ResourceNotFound
          # do nothing
        end
      end

      # Returns the portage package control file name:
      # =net-analyzer/nagios-core-3.1.2 => chef-net-analyzer-nagios-core-3-1-2
      # =net-analyzer/netdiscover => chef-net-analyzer-netdiscover
      def package_conf_file(conf_type, name)
        conf_dir = "/etc/portage/package.#{conf_type}"
        package_atom = name.strip.split(/\s+/).first
        package_file = package_atom.gsub(/[\/\.|]/, "-").gsub(/[^a-z0-9_\-]/i, "")
        return "#{conf_dir}/chef-#{package_file}"
      end

      def same_content?(filepath, content)
        content.strip == ::File.read(filepath).strip
      end

      def create_package_conf_file(conf_file, package, flags)
        content = [package, [flags].compact.flatten.sort.uniq.join(' ')].join(' ')
        return nil if ::File.exists?(conf_file) && same_content?(conf_file, content)
        run("echo -e '#{content}' | /usr/bin/sudo -H /usr/bin/tee #{conf_file}")
        true
      end

      def delete_package_conf_file(conf_file)
        return nil unless ::File.exists?(conf_file)
        run("/usr/bin/sudo -H /bin/rm -rf #{conf_file}")
        true
      end

      def run(command)
        Chef::Mixin::Command.run_command_with_systems_locale(command: command)
      end
    end
  end
end

# monkeypatch Chefs portage provider with eix and USE flag change detection
class Chef
  class Provider
    class Package
      class Portage < Chef::Provider::Package

        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          if package_info and package_info[:current_version]
            @current_resource.version(package_info[:current_version])
          end
          @current_resource
        end

        def candidate_version
          @candidate_version ||= package_info[:candidate_version] rescue nil
        end

        def install_package(name, version)
          pkg = "=#{name}-#{version}"

          if(version =~ /^\~(.+)/)
            # If we start with a tilde
            pkg = "~#{name}-#{$1}"
          end

          run_command_with_systems_locale(
            :command => "/usr/bin/sudo -H /usr/bin/emerge --color=n --nospinner --quiet -Nnu #{expand_options(@new_resource.options)} #{pkg}"
          )
        end

        def action_install
          # If we specified a version, and it's not the current version, move to the specified version
          if !@new_resource.version.nil? && !(target_version_already_installed?)
            install_version = @new_resource.version
            # If it's not installed at all, install it
          elsif @current_resource.version.nil?
            install_version = candidate_version
          else
            Chef::Log.debug("#{@new_resource} is already installed - nothing to do")
            return
          end

          # We need to make sure we handle the preseed file
          if @new_resource.response_file
            if preseed_file = get_preseed_file(@new_resource.package_name, install_version)
              converge_by("preseed package #{@new_resource.package_name}") do
                preseed_package(preseed_file)
              end
            end
          end
          description = install_version ? "version #{install_version} of" : ""
          converge_by("install #{description} package #{@new_resource.package_name}") do
            @new_resource.version(install_version)
            install_package(@new_resource.package_name, install_version)
          end
        end

        def action_upgrade
          @new_resource.version(candidate_version)
          converge_by("upgrade package #{@new_resource.package_name}") do
            upgrade_package(@new_resource.package_name, candidate_version)
            Chef::Log.info("#{@new_resource} upgraded package")
          end
        end

        def package_info
          packages_cache_from_eix
          @@packages_cache[@new_resource.package_name].tap do |pkg|
            if pkg
              pkg.merge!({
                :package_atom => full_package_atom(@new_resource.package_name, @new_resource.version)
              })
            end
          end
        end

        def packages_cache_from_eix
          @@packages_cache ||= {}
          packages_cache_from_eix! if @@packages_cache.empty?
        end

        def packages_cache_from_eix!
          eix = "/usr/bin/eix"
          eix_update = "/usr/bin/sudo -H /usr/bin/eix-update"

          unless ::File.executable?(eix)
            raise Chef::Exceptions::Package, "You need to install app-portage/eix for fast package searches."
          end

          # We need to update the eix database if it's older than the current portage
          # tree or the eix binary.
          if ::File.directory?("/var/cache/eix")
            cache_file = "/var/cache/eix/portage.eix"
          else
            cache_file = "/var/cache/eix"
          end

          unless ::FileUtils.uptodate?(cache_file, [eix, "/usr/portage/metadata/timestamp"])
            Chef::Log.debug("eix database outdated, calling `#{eix_update}`.")
            Chef::Mixin::Command.run_command_with_systems_locale(:command => eix_update)
          end

          query_command = [
            eix,
            "--nocolor",
            "--pure-packages",
            '--format "<category>/<name>\t<bestversion:PVERSION>\t<installedversions:PVERSION>\n"',
          ].join(" ")

          eix_stderr = nil
          @@packages_cache = {}

          Chef::Log.debug("Calling `#{query_command}`.")
          status = popen4(query_command) do |pid, stdin, stdout, stderr|
            eix_stderr = stderr.read
            stdout.readlines.each do |line|
              pn, candidate, current = line.split(/\t/)
              @@packages_cache[pn] = {
                :current_version => current.split(/\s/).last,
                :candidate_version => candidate,
              }
            end
          end

          unless status.exitstatus == 0
            raise Chef::Exceptions::Package, "eix search failed: `#{query_command}`\n#{eix_stderr}\n#{status.inspect}!"
          end
        end

        def full_package_atom(package_atom, version = nil)
          return package_atom unless version

          if version =~ /^\~(.+)/
            "~#{package_atom}-#{$1}"
          else
            "=#{package_atom}-#{version}"
          end
        end

      end
    end
  end
end
