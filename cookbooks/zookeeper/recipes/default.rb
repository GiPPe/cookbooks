include_recipe "java"

if gentoo?
  package "sys-cluster/zookeeper"
elsif mac_os_x?
  package "zookeeper"
end

if root? or mac_os_x?
  template "#{node[:zookeeper][:bindir]}/zkServer.sh" do
    source "zkServer.sh"
    mode "0755"
    notifies :restart, "service[zookeeper]"
  end

  template "#{node[:zookeeper][:confdir]}/log4j.properties" do
    source "log4j.properties"
    mode "0644"
    notifies :restart, "service[zookeeper]"
  end

  template "#{node[:zookeeper][:confdir]}/zoo.cfg" do
    source "zoo.cfg"
    mode "0644"
    notifies :restart, "service[zookeeper]"
  end

  directory node[:zookeeper][:datadir] do
    owner "zookeeper"
    recursive true
  end

  file "#{node[:zookeeper][:datadir]}/myid" do
    content "#{node[:zookeeper][:myid]}\n"
    mode "0644"
    notifies :restart, "service[zookeeper]"
  end

  systemd_unit "zookeeper.service"

  service "zookeeper" do
    action [:enable, :start]
    only_if { root? }
  end

  systemd_timer "zookeeper-cleanup" do
    schedule %w(OnCalendar=3:00)
    unit(command: "#{node[:zookeeper][:bindir]}/zkCleanup.sh #{node[:zookeeper][:datadir]} -n 5")
  end
end

if nagios_client?
  nagios_plugin "check_zookeeper" do
    source "check_zookeeper.rb"
  end

  nrpe_command "check_zookeeper_status" do
    command "/usr/lib/nagios/plugins/check_zookeeper -m Status -H localhost"
  end

  nagios_service "ZOOKEEPER-STATUS" do
    check_command "check_nrpe!check_zookeeper_status"
  end

  nrpe_command "check_zookeeper_readonly" do
    command "/usr/lib/nagios/plugins/check_zookeeper -m ReadOnly -H localhost"
  end

  nagios_service "ZOOKEEPER-READONLY" do
    check_command "check_nrpe!check_zookeeper_readonly"
  end

  if zookeeper_nodes.count > 1
    nrpe_command "check_zookeeper_followers" do
      command "/usr/lib/nagios/plugins/check_zookeeper -m Followers -n #{zookeeper_nodes.map { |n| n[:ipaddress] }.join(" -n ")}"
    end

    nagios_service "ZOOKEEPER-FOLLOWERS" do
      check_command "check_nrpe!check_zookeeper_followers"
    end
  end

  {
    :connections => [2000, 3000],
    :watches => [100000, 200000],
    :latency => [1000, 2000],
    :requests => [20, 50],
    :files => [2048, 4096],
  }.each do |mode, threshold|
    nrpe_command "check_zookeeper_#{mode}" do
      command "/usr/lib/nagios/plugins/check_zookeeper -m #{mode.capitalize} -H localhost -w #{threshold[0]} -c #{threshold[1]}"
    end

    nagios_service "ZOOKEEPER-#{mode.to_s.upcase}" do
      check_command "check_nrpe!check_zookeeper_#{mode}"
    end
  end
end
