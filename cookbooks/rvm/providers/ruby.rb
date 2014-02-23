include ChefUtils::RVM

def load_current_resource
  @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
  @ruby_string = new_resource.ruby_string

  @rvm_env = ::RVM::ChefUserEnvironment.new(
    new_resource.user, "default",
    :rvm_rubygems_version => new_resource.rubygems_version,
    :source_environment => false
  )
end

action :install do
  if ruby_installed?(@ruby_string)
    Chef::Log.debug("rvm_ruby[#{@rubie}] is already installed, so skipping")
  else
    install_ruby_dependencies(@rubie)

    Chef::Log.info("Building rvm_ruby[#{@rubie}], this could take awhile...")
    install_start = Time.now

    if @rvm_env.install(@rubie, :rvm_by_path => true, :'verify-downloads' => 2)
      Chef::Log.info("Installation of rvm_ruby[#{@rubie}] was successful.")
      @rvm_env.use(@rubie)
      update_installed_rubies
      new_resource.updated_by_last_action(true)

      Chef::Log.info("Importing initial gemsets for rvm_ruby[#{@rubie}]")
      if @rvm_env.gemset_initial
        Chef::Log.debug("Initial gemsets for rvm_ruby[#{@rubie}] are installed")
      else
        Chef::Log.warn("Failed to install initial gemsets for rvm_ruby[#{@rubie}]")
      end
    else
      raise "Failed to install rvm_ruby[#{@rubie}]. " +
        "Check logs in #{::RVM.path}/log/#{@rubie}"
    end

    Chef::Log.info("rvm_ruby[#{@rubie}] build time was " +
      "#{(Time.now - install_start)/60.0} minutes.")
  end
end

action :uninstall do
  if ruby_installed?(@rubie)
    Chef::Log.info("Uninstalling rvm_ruby[#{@rubie}]")

    if @rvm_env.uninstall(@rubie, :rvm_by_path => true)
      update_installed_rubies
      Chef::Log.debug("Uninstallation of rvm_ruby[#{@rubie}] was successful.")
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.warn("Failed to uninstall rvm_ruby[#{@rubie}]. " +
        "Check logs in #{::RVM.path}/log/#{@rubie}")
    end
  else
    Chef::Log.debug("rvm_ruby[#{@rubie}] was not installed, so skipping")
  end
end

action :remove do
  if ruby_installed?(@rubie)
    Chef::Log.info("Removing rvm_ruby[#{@rubie}]")

    if @rvm_env.remove(@rubie, :rvm_by_path => true)
      update_installed_rubies
      Chef::Log.debug("Removal of rvm_ruby[#{@rubie}] was successful.")
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.warn("Failed to remove rvm_ruby[#{@rubie}]. " +
        "Check logs in #{::RVM.path}/log/#{@rubie}")
    end
  else
    Chef::Log.debug("rvm_ruby[#{@rubie}] was not installed, so skipping")
  end
end

private

##
# Installs any package dependencies needed by a given ruby
#
# @param [String, #to_s] the fully qualified RVM ruby string
def install_ruby_dependencies(rubie)
  pkgs = []
  case rubie
  when /^ruby-/, /^ree-/, /^rbx-/, /^kiji/
    case node['platform']
    when "debian", "ubuntu"
      pkgs += %w{
        autoconf
        automake
        bison
        build-essential
        libc6-dev
        libreadline6
        libreadline6-dev
        libsqlite3-dev
        libssl-dev
        libtool
        libxml2-dev
        libxslt-dev
        libyaml-dev
        ncurses-dev
        openssl
        sqlite3
        ssl-cert
        zlib1g
        zlib1g-dev
      }
    when "gentoo"
      pkgs += %w{
        app-shells/bash
        dev-db/sqlite
        dev-libs/libxslt
        dev-libs/libyaml
        dev-libs/openssl
        dev-vcs/git
        net-misc/curl
        sys-devel/autoconf
        sys-devel/automake
        sys-devel/bison
        sys-devel/gcc
        sys-devel/libtool
        sys-devel/m4
        sys-devel/patch
        sys-libs/readline
        sys-libs/zlib
        virtual/libiconv
      }
    end

  when /^jruby/
    case node['platform']
    when "debian", "ubuntu"
      pkgs += %w{
        g++
      }
    when "gentoo"
      pkgs += %w{
        sys-devel/gcc
      }
    end
  end

  pkgs.each do |pkg|
    package "#{pkg}-#{rrand}" do
      package_name pkg
      action :nothing
    end.run_action(:install)
  end
end
