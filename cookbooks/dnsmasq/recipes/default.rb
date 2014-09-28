package "net-dns/dnsmasq"

directory "/etc/dnsmasq.d" do
  owner "root"
  group "root"
  mode "0750"
end

cookbook_file "/etc/dnsmasq.conf" do
  source "dnsmasq.conf"
  owner "root"
  group "root"
  mode "0640"
end
