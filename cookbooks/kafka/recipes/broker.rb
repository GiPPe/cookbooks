include_recipe "kafka"

node[:kafka][:storage].split(',').each do |dir|
  directory dir do
    owner "kafka"
    group "kafka"
    mode "0755"
  end
end

node.default[:kafka][:zookeeper][:cluster] = node.cluster_name

template "/var/app/kafka/current/config/server.properties" do
  source "server.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
  notifies :create, "ruby_block[kafka-zk-chroot]"
end

include_recipe "zookeeper::ruby"

ruby_block "kafka-zk-chroot" do
  action :nothing
  block do
    require 'zk'
    ZK.new(zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster]))
  end
end

systemd_unit "kafka.service"

service "kafka" do
  action [:enable, :start]
end
