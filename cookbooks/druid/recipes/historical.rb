include_recipe "druid"

systemd_unit "druid-historical.service" do
  template "druid-service"
  variables({
    druid_service: "historical",
  })

  notifies :restart, "service[druid-historical]", :immediately
end

template "/usr/libexec/druid-historical" do
  source "druid-runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables({
    druid_service:  "historical",
    druid_port:     node[:druid][:historical][:port],
    druid_mx:       node[:druid][:historical][:mx],
    druid_dm:       node[:druid][:historical][:dm],
  })
  
  notifies :restart, "service[druid-historical]", :immediately
end

service "druid-historical" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
