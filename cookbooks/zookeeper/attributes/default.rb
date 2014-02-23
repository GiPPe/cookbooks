if gentoo?
  default[:zookeeper][:confdir] = "/opt/zookeeper/conf"
  default[:zookeeper][:bindir] = "/opt/zookeeper/bin"
  default[:zookeeper][:datadir] = "/var/lib/zookeeper"
elsif mac_os_x?
  default[:zookeeper][:confdir] = "/usr/local/etc/zookeeper"
  default[:zookeeper][:bindir] = "/usr/local/bin"
  default[:zookeeper][:datadir] = "/usr/local/var/zookeeper"
end

default[:zookeeper][:myid] = node[:cluster][:host][:id]
