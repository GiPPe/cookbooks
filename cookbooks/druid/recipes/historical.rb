include_recipe "druid"

systemd_unit "druid-historical.service" do
  template "druid.service"
  notifies :restart, "service[druid-historical]", :immediately
end

template "/var/app/druid/bin/druid-historical" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[druid-historical]", :immediately
  variables service: "historical"
end

service "druid-historical" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
