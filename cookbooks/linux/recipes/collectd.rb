collectd_plugin "cpu"
collectd_plugin "contextswitch"

collectd_plugin "df" do
  source "df.conf"
end

collectd_plugin "disk"
collectd_plugin "dns"
collectd_plugin "entropy"
collectd_plugin "irq"
collectd_plugin "load"
collectd_plugin "memory"
collectd_plugin "netlink"

collectd_plugin "ping" do
  source "ping.conf"
  only_if { nagios_node }
end

collectd_plugin "processes"
collectd_plugin "swap"
collectd_plugin "uptime"
collectd_plugin "vmem"
