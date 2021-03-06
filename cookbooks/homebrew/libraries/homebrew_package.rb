# Chef package provider for Homebrew

require 'chef/provider/package'
require 'chef/resource/package'
require 'chef/platform'

class Chef
  class Provider
    class Package
      class Homebrew < Package
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @current_resource.version(current_installed_version)
          @current_resource
        end

        def install_package(name, version)
          brew('install', name)
        end

        # Homebrew doesn't really have a notion of upgrading packages, just
        # install the latest version?
        def upgrade_package(name, version)
          if @current_resource.version
            brew('upgrade', name) if @current_resource.version != candidate_version
          else
            install_package(name, version)
          end
        end

        def remove_package(name, version)
          brew('uninstall', name)
        end

        # Homebrew doesn't really have a notion of purging, so just remove.
        def purge_package(name, version)
          remove_package(name, version)
        end

        protected

        def brew_command
          "env -i PATH=$PATH HOME=$HOME /usr/local/bin/brew"
        end

        def brew(*args)
          run_command_with_systems_locale(
            :command => "#{brew_command} #{args.join(' ')}"
          )
        end

        def current_installed_version
          get_version_from_command("#{brew_command} list --versions | awk '/^#{@new_resource.package_name} / { print $NF }'")
        end

        def candidate_version
          brew_version = %x[#{brew_command} --version].strip
          if Gem::Version.new(brew_version) >= Gem::Version.new('0.9.2')
            command = "#{brew_command} info #{@new_resource.package_name} | awk '/^#{@new_resource.package_name}:/ { print $3 }'"
          else
            command = "#{brew_command} info #{@new_resource.package_name} | awk '/^#{@new_resource.package_name} / { print $2 }'"
          end
          get_version_from_command(command)
        end

        def get_version_from_command(command)
          version = get_response_from_command(command).chomp
          version.empty? ? nil : version.chomp(',')
        end

        # Nicked from lib/chef/package/provider/macports.rb and tweaked
        # slightly.
        def get_response_from_command(command)
          output = nil
          status = popen4(command) do |pid, stdin, stdout, stderr|
            begin
              output = stdout.read
            rescue Exception => e
              raise Chef::Exceptions::Package, "Could not read from STDOUT on command: #{command}\nException: #{e.inspect}"
            end
          end
          unless (0..1).include? status.exitstatus
            raise Chef::Exceptions::Package, "#{command} failed - #{status.inspect}"
          end
          output
        end
      end
    end
  end
end

Chef::Platform.set :platform => :mac_os_x, :resource => :package, :provider => Chef::Provider::Package::Homebrew
