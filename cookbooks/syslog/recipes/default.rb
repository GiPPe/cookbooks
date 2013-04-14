package "app-admin/syslog-ng"

directory "/etc/syslog-ng/conf.d" do
  action :delete
  recursive true
end

indexer_nodes = node.run_state[:nodes].select do |n|
  n[:tags].include?("splunk-indexer") rescue false
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[syslog-ng]"
  variables :indexer_nodes => indexer_nodes
end

service "syslog-ng" do
  if systemd_running?
    action [:disable, :stop]
  else
    action [:enable, :start]
  end
end

include_recipe "syslog::logrotate"

if tagged?("nagios-client") and not systemd_running?
  nrpe_command "check_syslog" do
    command "/usr/lib/nagios/plugins/check_systemd syslog-ng.service /run/syslog-ng.pid /usr/sbin/syslog-ng"
  end

  nagios_service "SYSLOG" do
    check_command "check_nrpe!check_syslog"
    servicegroups "system"
    env [:testing, :development]
  end
end
