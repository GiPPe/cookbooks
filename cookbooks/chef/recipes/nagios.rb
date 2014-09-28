if nagios_client?
  nagios_plugin "check_chef_clients"

  sudo_rule "nagios-chef-clients" do
    user "nagios"
    runas "ALL"
    command "NOPASSWD: /usr/bin/knife status -H *"
  end

  nrpe_command "check_chef_clients" do
    command "/usr/lib/nagios/plugins/check_chef_clients"
  end

  nagios_service "CHEF-CLIENTS" do
    check_command "check_nrpe!check_chef_clients"
  end
end
