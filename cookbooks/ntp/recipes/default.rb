if can_run_ntpd?
  if gentoo?
    package "net-misc/ntp" do
      notifies :restart, "service[ntpd]"
    end
  elsif debian_based?
    package "ntp"
  else
    raise "cookbook ntp does not support platform #{node[:platform]}"
  end

  template "/etc/ntp.conf" do
    source "ntp.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[ntpd]"
  end

  systemd_unit "ntpd.service"

  service "ntpd" do
    service_name "ntp" if debian_based?
    action [:enable, :start]
  end

  if nagios_client?
    nrpe_command "check_time" do
      command "/usr/lib/nagios/plugins/check_ntp_time -H pool.ntp.org -w 5 -c 30"
    end

    nagios_service "TIME" do
      check_command "check_nrpe!check_time"
      servicegroups "system"
      env [:testing, :development]
    end
  end
end
