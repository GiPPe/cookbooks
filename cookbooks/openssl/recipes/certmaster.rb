include_recipe "openssl"

remote_directory "/etc/ssl/ca" do
  source "certificates"
  cookbook "certificates"
  files_owner "root"
  files_group "root"
  files_mode "0444"
  files_backup 0
  purge true
  owner "root"
  group "root"
  mode "0755"
end

if nagios_client?
  nagios_plugin "check_ssl_cert"
  nagios_plugin "check_ssl_certs"

  nrpe_command "check_ssl_certs" do
    command "/usr/lib/nagios/plugins/check_ssl_certs"
  end

  nagios_service "CA-CERTS" do
    check_command "check_nrpe!check_ssl_certs"
    notification_interval 1440
  end
end
