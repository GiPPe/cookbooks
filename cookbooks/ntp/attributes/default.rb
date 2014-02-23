%x(whois #{node[:primary_ipaddress]} | grep -q HETZNER-RZ)
if $?.exitstatus == 0
  default[:ntp][:server] = %w(
    ntp1.hetzner.de
    ntp2.hetzner.com
    ntp3.hetzner.net
  )
else
  default[:ntp][:server] = %w(
    0.de.pool.ntp.org
    1.de.pool.ntp.org
    2.de.pool.ntp.org
    3.de.pool.ntp.org
  )
end
