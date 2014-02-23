include_recipe "druid"

node.default[:druid][:logger] = true

systemd_unit "druid-realtime.service" do
  template "druid-service"
  variables({
    druid_service: "realtime",
  })

  notifies :restart, "service[druid-realtime]", :immediately
end

template "/usr/libexec/druid-realtime" do
  source "druid-runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables({
    druid_service:  "realtime",
    druid_port:     node[:druid][:realtime][:port],
    druid_mx:       node[:druid][:realtime][:mx],
    druid_dm:       node[:druid][:realtime][:dm],
  })
  
  notifies :restart, "service[druid-realtime]", :immediately
end

service "druid-realtime" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
  subscribes :restart, "template[/etc/druid/realtime.spec]"
end
