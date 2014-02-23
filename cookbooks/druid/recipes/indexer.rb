include_recipe "druid"

systemd_unit "druid-indexer.service" do
  template "druid-service"
  variables({
    druid_service: "indexer",
  })

  notifies :restart, "service[druid-indexer]", :immediately
end

template "/usr/libexec/druid-indexer" do
  source "druid-runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables({
    druid_service:  "middleManager",
    druid_port:     node[:druid][:indexer][:port],
    druid_mx:       node[:druid][:indexer][:mx],
    druid_dm:       node[:druid][:indexer][:dm],
  })
  
  notifies :restart, "service[druid-indexer]", :immediately
end

service "druid-indexer" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/etc/druid/log4j.properties]"
end
