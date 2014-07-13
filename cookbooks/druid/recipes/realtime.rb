include_recipe "druid"

template "/etc/druid/realtime.spec" do
  source "realtime.spec"
  owner "root"
  group "root"
  mode "0644"
end

template "/var/app/druid/bin/druid-realtime" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[druid-realtime]"
  variables service: "realtime"
end

systemd_unit "druid-realtime.service" do
  template "druid.service"
  notifies :restart, "service[druid-realtime]"
end

service "druid-realtime" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/log4j.properties]"
  subscribes :restart, "template[/etc/druid/realtime.spec]"
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/bin/druid-realtime]"
  subscribes :restart, "systemd_unit[druid-realtime]"
end
