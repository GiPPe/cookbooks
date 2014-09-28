cookbook_file "/usr/bin/lib_users" do
  source "lib_users.py"
  owner "root"
  group "root"
  mode "0755"
end

if nagios_client?
  sudo_rule "nagios-lib_users" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/bin/lib_users"
  end

  nagios_plugin "check_lib_users"

  nrpe_command "check_lib_users" do
    command "/usr/lib/nagios/plugins/check_lib_users"
  end

  nagios_service "LIB-USERS" do
    check_command "check_nrpe!check_lib_users"
    notification_period "never"
    env [:testing, :development]
  end
end
