portage_package_use "net-misc/openvpn" do
  use %w(iproute2)
end

package "net-misc/openvpn"

directory "/etc/ssl/openvpn"

ssl_dh "/etc/ssl/openvpn/dh.pem" do
  owner "openvpn"
  notifies :restart, "service[openvpn]"
end

ssl_ca "/etc/ssl/openvpn/ca" do
  owner "openvpn"
  notifies :restart, "service[openvpn]"
end

ssl_certificate "/etc/ssl/openvpn/server" do
  cn node[:fqdn]
  owner "openvpn"
  notifies :restart, "service[openvpn]"
end

template "/etc/openvpn/openvpn.conf" do
  source "openvpn.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[openvpn]"
end

systemd_unit "openvpn.service"

service "openvpn" do
  action [:enable, :start]
end

shorewall_rule "openvpn" do
  destport "1194"
end

shorewall_zone "vpn"

shorewall_interface "vpn" do
  interface "tun0 - routeback"
end

shorewall_tunnel "vpn" do
  vpntype "openvpnserver"
  zone "net"
  gateway "0.0.0.0/0"
end

shorewall_policy "vpn" do
  source "vpn"
  dest "all"
  policy "ACCEPT"
end

cidr = IPAddr.new(node[:openvpn][:netmask]).to_i.to_s(2).count("1")

shorewall_masq "vpn" do
  interface node[:network][:default_interface]
  source "#{node[:openvpn][:network]}/#{cidr}"
end
