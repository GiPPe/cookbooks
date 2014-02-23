if !guest?
  if gentoo?
    package "app-emulation/lxc"
    package "net-misc/bridge-utils"
    package "dev-util/debootstrap"
  elsif debian_based?
    package "lxc"
    package "bridge-utils"
    package "debootstrap"
  end

  directory "/usr/share/lxc" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/usr/share/lxc/templates" do
    owner "root"
    group "root"
    mode "0755"
  end

  %w(gentoo ubuntu).each do |platform|
    cookbook_file "/usr/share/lxc/templates/lxc-#{platform}" do
      source "lxc-#{platform}"
      owner "root"
      group "root"
      mode "0755"
    end
  end

  systemd_unit "lxc@.service"
end
