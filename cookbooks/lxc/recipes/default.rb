include_recipe "debootstrap"

if gentoo?
  package "app-emulation/lxc"
  package "net-misc/bridge-utils"
elsif debian_based?
  package "lxc"
  package "bridge-utils"
end

directory "/lxc" do
  owner "root"
  group "root"
  mode "0755"
end

cookbook_file "/usr/libexec/lxc/lxc-start" do
  source "start.sh"
  owner "root"
  group "root"
  mode "0755"
end

template "/usr/libexec/lxc/lxc-gateway" do
  source "gateway.sh"
  owner "root"
  group "root"
  mode "0750"
end

cookbook_file "/etc/lxc/lxc.conf" do
  source "lxc.conf"
  owner "root"
  group "root"
  mode "0640"
end

template "/etc/lxc/default.conf" do
  source "default.conf"
  owner "root"
  group "root"
  mode "0640"
end

cookbook_file "/etc/dhcpcd.conf" do
  source "dhcpcd.conf"
  owner "root"
  group "root"
  mode "0640"
end

systemd_unit "lxc-network.service"

service "lxc-network" do
  action [:enable, :start]
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
