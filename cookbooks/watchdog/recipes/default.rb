if !vbox?
  if gentoo?
    package "sys-apps/watchdog"

    cookbook_file "/etc/watchdog.conf" do
      source "watchdog.conf"
      owner "root"
      group "root"
      mode "0644"
    end

    systemd_unit "watchdog.service"

    service "watchdog" do
      if File.exist?("/dev/watchdog")
        action [:enable, :start]
      else
        action [:disable, :stop]
      end
    end

  elsif debian_based?
    # Currently blocked by amc!?
    #package "watchdog"
  end
end
