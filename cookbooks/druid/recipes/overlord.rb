include_recipe "druid"

systemd_unit "druid-overlord.service" do
  template "druid-service"
  variables({
    druid_service: "overlord",
  })

  notifies :restart, "service[druid-overlord]", :immediately
end

template "/usr/libexec/druid-overlord" do
  source "druid-runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables({
    druid_service:  "overlord",
    druid_port:     node[:druid][:overlord][:port],
    druid_mx:       node[:druid][:overlord][:mx],
    druid_dm:       node[:druid][:overlord][:dm],
  })
  
  notifies :restart, "service[druid-overlord]", :immediately
end

service "druid-overlord" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
