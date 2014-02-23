include_recipe "druid"

node.default[:druid][:logger] = true

systemd_unit "druid-broker.service" do
  template "druid-service"
  variables({
    druid_service: "broker",
  })

  notifies :restart, "service[druid-broker]", :immediately
end

template "/usr/libexec/druid-broker" do
  source "druid-runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables({
    druid_service:  "broker",
    druid_port:     node[:druid][:broker][:port],
    druid_mx:       node[:druid][:broker][:mx],
    druid_dm:       node[:druid][:broker][:dm],
  })
  
  notifies :restart, "service[druid-broker]", :immediately
end

service "druid-broker" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
