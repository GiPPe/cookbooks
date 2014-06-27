if gentoo?
  package "sys-apps/smartmontools"
elsif debian_based?
  package "smartmontools"
else
  raise "cookbook smart does not support #{node[:platform]}"
end

if node[:smart][:devices].any?
  cookbook_file "/usr/local/sbin/diskreport" do
    source "diskreport.sh"
    owner "root"
    group "root"
    mode "0755"
  end

  systemd_unit "smartd.service"

  service "smartd" do
    service_name "smartd"
    service_name "smartmontools" if debian_based?
    action [:disable, :stop]
  end

  if nagios_client?
    nagios_plugin "check_smart"

    sudo_rule "nagios-smartctl" do
      user "nagios"
      runas "root"
      command "NOPASSWD: /usr/sbin/smartctl"
    end

    node[:smart][:devices].each do |d|
      next unless File.exist?(d)

      devname = d.sub("/dev/", "")

      nrpe_command "check_smart_#{devname}" do
        command "/usr/lib/nagios/plugins/check_smart -d #{d}"
      end

      nagios_service "SMART_#{devname.upcase}" do
        check_command "check_nrpe!check_smart_#{devname}"
        check_interval 60
        notification_interval 180
        env [:testing, :development]
      end
    end
  end
end
