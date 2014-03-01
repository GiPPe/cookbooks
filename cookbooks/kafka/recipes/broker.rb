include_recipe "kafka"

folders = ['/var/log/kafka'] + node[:kafka][:storage].split(',')

folders.each do |dir|
  directory dir do
    owner "kafka"
    group "kafka"
    mode "0755"
  end
end

node.default[:kafka][:zookeeper][:cluster] = node.cluster_name

template "/etc/kafka/server.config" do
  source "server.config"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

systemd_unit "kafka.service"

service "kafka" do
  action [:enable, :start]
end

if nagios_client?

  # Nothing generic, add a site-specific cookbook

end
