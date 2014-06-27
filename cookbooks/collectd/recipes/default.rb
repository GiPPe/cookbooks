if gentoo?
  package "app-admin/collectd"
else
  raise "platform not supported"
end

template "/etc/collectd.conf" do
  source "collectd.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[collectd]"
end

directory "/etc/collectd.d" do
  owner "root"
  group "root"
  mode "0644"
end

service "collectd" do
  action [:enable, :start]
end
