include_recipe "druid"

if vbox?
  include_recipe "mysql::server"
  mysql_database "druid"
end

template "/var/app/druid/bin/druid-coordinator" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[druid-coordinator]"
  variables service: "coordinator"
end

systemd_unit "druid-coordinator.service" do
  template "druid.service"
  notifies :restart, "service[druid-coordinator]"
end

service "druid-coordinator" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/druid/log4j.properties]"
  subscribes :restart, "template[/etc/druid/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/bin/druid-coordinator]"
  subscribes :restart, "systemd_unit[druid-coordinator]"
end

if nagios_client?
  nrpe_command "check_druid_usage" do
    command "/usr/lib/nagios/plugins/check_druid -m Usage -u http://localhost:#{node[:druid][:coordinator][:port]}/info/servers?full -w 90 -c 95"
  end

  nagios_service "DRUID-USAGE" do
    check_command "check_nrpe!check_druid_usage"
    servicegroups "druid"
  end

  druid_databases = node[:druid][:nagios][:topics]

  whitelist = SortedSet.new

  node[:druid][:nagios][:whitelist].each do |white_range|
    start, stop = white_range.split('/').map {|t| Time.parse(t).to_i / 3600 * 3600 }
    start.step(stop-1, 3600) do |hour| # right hand side non-inclusive, hence -1
      whitelist << Time.at(hour).utc.iso8601
    end
  end

  druid_databases.each do |db_name|
    nagios_cmd = "/usr/lib/nagios/plugins/check_druid -m Intervals -u http://localhost:#{node[:druid][:coordinator][:port]}/info/servers?full -d #{db_name}"
    if whitelist.any?
      nagios_cmd += " -W #{whitelist.to_a.join(',')}"
    end

    nrpe_command "check_druid_db_#{db_name}" do
      command nagios_cmd
    end

    nagios_service "DRUID-DB-#{db_name.gsub(/_/, '-').upcase}" do
      check_command "check_nrpe!check_druid_db_#{db_name}"
      servicegroups "druid"
    end
  end
end
