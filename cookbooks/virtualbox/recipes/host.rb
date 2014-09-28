if gentoo?
	if zentoo?
		package "app-emulation/virtualbox"
	else
		portage_package_use "media-libs/libsdl" do
			use %w(X)
		end
		package "app-emulation/virtualbox-bin"
	end
  package "app-emulation/vagrant"

  if root?
    file "/etc/modules-load.d/virtualbox.conf" do
      content "vboxnetflt\nvboxnetadp\nvboxpci\nvboxdrv\n"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, 'service[systemd-modules-load.service]'
    end

    shorewall_interface "net" do
      interface "vboxnet+ 0.0.0.0 optional"
    end
  end

elsif mac_os_x?
  mac_package "VirtualBox" do
    source "http://download.virtualbox.org/virtualbox/4.3.2/VirtualBox-4.3.2-90405-OSX.dmg"
    type "dmg_pkg"
  end

  mac_package "Vagrant" do
    source "http://files.vagrantup.com/packages/a40522f5fabccb9ddabad03d836e120ff5d14093/Vagrant-1.3.5.dmg"
    type "dmg_pkg"
  end
end
