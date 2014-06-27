include_recipe "druid"

systemd_unit "druid-broker.service" do
  template "druid.service"
  notifies :restart, "service[druid-broker]", :immediately
end

template "/var/app/druid/bin/druid-broker" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[druid-broker]", :immediately
  variables service: "broker"
end

service "druid-broker" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
