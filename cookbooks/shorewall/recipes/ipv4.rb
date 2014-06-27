if gentoo?
  package "net-firewall/shorewall"

elsif debian_based?
  package "shorewall"

end

directory "/etc/shorewall" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall/shorewall.conf" do
  source "ipv4/shorewall.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :restart, "service[shorewall]"
end

%w(
  accounting
  hosts
  interfaces
  masq
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall/#{t}" do
    source "ipv4/#{t}"
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, "service[shorewall]"
  end
end

if debian_based?
  file "/etc/default/shorewall" do
    content "startup=1\n"
    owner "root"
    group "root"
    mode "0644"
  end
end

systemd_unit "shorewall.service" do
  template true
end

service "shorewall" do
  action [:enable, :start]
end

splunk_input "monitor:///var/log/shorewall-init.log"

if nagios_client?
  sudo_rule "nagios-shorewall" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /sbin/shorewall status"
  end

  nagios_plugin "check_shorewall"

  nrpe_command "check_shorewall" do
    command "/usr/lib/nagios/plugins/check_shorewall"
  end

  nagios_service "SHOREWALL" do
    check_command "check_nrpe!check_shorewall"
    servicegroups "system"
    env [:testing, :development]
  end
end
