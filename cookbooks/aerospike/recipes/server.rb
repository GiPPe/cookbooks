package "dev-db/aerospike"

template "/etc/aerospike/aerospike.conf" do
  source "aerospike.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[aerospike]"
end

systemd_unit "aerospike.service" do
  template true
end

service "aerospike" do
  action [:enable, :start]
end

service "amc" do
  action [:enable, :start]
end
