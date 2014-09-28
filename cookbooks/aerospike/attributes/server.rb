default[:aerospike][:fd_max] = 15000
default[:aerospike][:namespaces][:test] = {
  replication_factor: 2,
  memory_size: "128M",
  default_ttl: "30d",
  storage_engine: "memory",
}
