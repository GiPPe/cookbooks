%x(whois #{node[:ipaddress]} | grep -q HETZNER-RZ)
if $?.exitstatus == 0
  default[:resolv][:nameservers] = %w(213.133.98.98 213.133.99.99)
else
  default[:resolv][:nameservers] = %w(4.2.2.2 8.8.8.8)
end
default[:resolv][:search] = []
default[:resolv][:hosts] = []
default[:resolv][:aliases] = []
