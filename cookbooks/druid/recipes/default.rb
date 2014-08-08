include_recipe "java"

deploy_skeleton "druid"

%w(
  /etc/druid
  /var/app/druid/storage
  /var/app/druid/storage/tmp
  /var/app/druid/storage/info
  /var/app/druid/storage/segment_cache
  /var/app/druid/storage/realtime
  /var/app/druid/storage/task
  /var/app/druid/storage/task_hadoop
).each do |dir|
  directory dir do
    owner "druid"
    group "druid"
    mode "0755"
  end
end

deploy_application "druid" do
  repository node[:druid][:git][:repository]
  revision node[:druid][:git][:revision]

  before_symlink do
    execute "mvn-clean-install" do
      command "/usr/bin/mvn clean install -DskipTests=true"
      cwd release_path
      user "druid"
      group "druid"
    end
  end
end

template "/etc/druid/log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/druid/runtime.properties" do
  source "runtime.properties"
  owner "root"
  group "root"
  mode "0644"
  notifies :create, "ruby_block[druid-zk-chroot]"
end

include_recipe "zookeeper::ruby"

ruby_block "druid-zk-chroot" do
  action :nothing
  block do
    require 'zk'
    ZK.new(zookeeper_connect(node[:druid][:zookeeper][:root], node[:druid][:cluster]))
  end
end

if nagios_client?
  nagios_plugin "check_druid" do
    source "check_druid.rb"
  end
end
