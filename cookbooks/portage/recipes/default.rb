if root?
  file "/etc/portage/package.mask/chef-app-portage-eix-0-28" do
    action :delete
  end

  package "sys-apps/portage"

  %w(eix elogv gentoolkit gentoolkit-dev portage-utils).each do |pkg|
    package "app-portage/#{pkg}"
  end

  group "portage" do
    gid 250
    append true
  end

  user "portage" do
    uid 250
    gid 250
    comment "portage"
    home "/var/tmp/portage"
    shell "/bin/false"
  end

  group "portage-#{rrand}" do
    group_name "portage"
    gid 250
    append true
    members %w(portage)
  end

  directory "/var/cache/portage" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory node[:portage][:distdir] do
    owner "root"
    group "portage"
  end

  # remove legacy paths
  file "/etc/make.conf" do
    action :delete
  end

  file "/etc/make.profile" do
    action :delete
  end

  link "/etc/portage/make.profile" do
    to node[:portage][:profile]
  end

  include_recipe "portage::layman"

  directory node[:portage][:confdir] do
    owner "root"
    group "root"
    mode "0755"
  end

  template node[:portage][:make_conf] do
    owner "root"
    group "root"
    mode "0644"
    source "make.conf"
    cookbook "portage"
    backup 0
  end

  %w(keywords mask unmask use).each do |type|
    path = "#{node[:portage][:confdir]}/package.#{type}"

    ruby_block "backup-package.#{type}" do
      block { FileUtils.mv(path, "#{path}.bak") }
      only_if { File.file?(path) }
    end

    directory path do
      owner "root"
      group "root"
      mode "0755"
      not_if { File.directory?(path) }
    end

    ruby_block "restore-package.#{type}" do
      block { FileUtils.mv("#{path}.bak", "#{path}/local") }
      only_if { File.file?("#{path}.bak") }
    end
  end

  cookbook_file "#{node[:portage][:confdir]}/bashrc" do
    source "bashrc"
    owner "root"
    group "root"
    mode "0644"
  end

  file "#{node[:portage][:confdir]}/repos.conf" do
    action :delete
    only_if { File.file?("#{node[:portage][:confdir]}/repos.conf") }
  end

  directory "#{node[:portage][:confdir]}/repos.conf" do
    action :delete
    recursive true
    only_if { File.directory?("#{node[:portage][:confdir]}/repos.conf") }
  end

  template "/usr/share/portage/config/repos.conf" do
    source "repos.conf"
    owner "root"
    group "root"
    mode "0644"
  end

  %w(
    /etc/logrotate.d/portage
    /etc/logrotate.d/elog-save-summary
  ).each do |f|
    file f do
      action :delete
    end
  end

  cookbook_file "/etc/dispatch-conf.conf" do
    source "dispatch-conf.conf"
    mode "0644"
    backup 0
  end

  cron_weekly "eclean-distfiles" do
    command "exec /usr/bin/eclean -d -n -q distfiles"
  end

  cron_weekly "eclean-packages" do
    command "exec /usr/bin/eclean -d -n -q packages"
  end

  execute "eix-update" do
    not_if do
      check_files = Dir.glob("/var/lib/layman/*/.git/index")
      check_files << "/usr/portage/metadata/timestamp.chk"

      if File.exist?("/var/cache/eix/portage.eix")
        cache_file = "/var/cache/eix/portage.eix"
      else
        cache_file = "/var/cache/eix"
      end

      FileUtils.uptodate?(cache_file, check_files)
    end
  end

  ruby_block "update-packages-cache" do
    action :nothing
    block do
      Gentoo::Portage::Emerge.packages_cache_from_eix!
    end
  end

  %w(
    cruft
    fake-preserved-libs
    remerge
    update-preserved-libs
    updateworld
    plibs
  ).each do |f|
    cookbook_file "/usr/local/sbin/#{f}" do
      source "scripts/#{f}"
      owner "root"
      group "root"
      mode "0755"
    end
  end

  if zenops_mirror_node
    rsync_module "portage-packages" do
      path "/usr/portage/packages"
      hosts_allow zenops_mirror_node[:primary_ipaddress]
      uid "nobody"
      gid "nobody"
    end
  end
end
