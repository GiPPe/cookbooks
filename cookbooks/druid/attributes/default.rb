default[:druid][:git][:repository] = "https://github.com/metamx/druid"
default[:druid][:git][:revision] = "druid-0.6.128"

default[:druid][:cluster] = node.cluster_name

default[:druid][:log4j][:full] = false

default[:druid][:nagios][:topics] = []
default[:druid][:nagios][:whitelist] = []

default[:dumbo][:git][:repository] = "https://github.com/liquidm/druid-dumbo"
default[:dumbo][:git][:revision] = "production"

default[:druid][:hadoop][:path] = "/var/app/hadoop2/current/bin"

# Modules
default[:druid][:core_extensions] = [
  "s3-extensions",
  "hdfs-storage",
  "kafka-eight",
]

default[:druid][:extensions] = []

# Curator Module / Discovery Module
default[:druid][:zookeeper][:root] = "/druid"
default[:druid][:zookeeper][:timeout] = 6000
default[:druid][:zookeeper][:discovery] = "/discovery"

# Druid Processing Module
default[:druid][:processing][:buffer] = 1073741824
default[:druid][:processing][:numThreads] = [node[:cpu][:total]-1, 1].max
default[:druid][:processing][:memory] = (node[:druid][:processing][:buffer]*(node[:druid][:processing][:numThreads]+1)/1048576.0)

# Metrics Module
default[:druid][:monitors] = []

# Storage Node Module
default[:druid][:server][:max_size] = 1 * 1024 * 1024 * 1024
default[:druid][:server][:tier] = "#{node[:cluster][:host][:group]}-#{node.cluster_name}"
default[:druid][:server][:priority] = 0

# DataSegment Pusher/Puller Module
default[:druid][:storage][:type] = "local"
default[:druid][:storage][:directory] = "/var/app/druid/storage"

# S3 Deep Storage
default[:druid][:storage][:s3][:access_key] = nil
default[:druid][:storage][:s3][:secret_key] = nil
default[:druid][:storage][:s3][:bucket] = nil
default[:druid][:storage][:s3][:base_key] = nil

# Indexing Services
default[:druid][:indexer][:port] = 8091
default[:druid][:indexer][:mx] = 2 * 1024
default[:druid][:indexer][:dm] = 64
default[:druid][:indexer][:runner][:javaOpts] = "-d64 -server -Xmx8g"
default[:druid][:indexer][:runner][:startPort] = 8092
default[:druid][:indexer][:workers] = [node[:cpu][:total]-1,1].max
default[:druid][:indexing][:service] = node.cluster_name

# Overlord Services
default[:druid][:overlord][:port] = 8090
default[:druid][:overlord][:mx] = 2 * 1024
default[:druid][:overlord][:dm] = 64

# Coordinator Services
default[:druid][:coordinator][:port] = 8081
default[:druid][:coordinator][:mx] = 2 * 1024
default[:druid][:coordinator][:dm] = 64

# Historical Services
default[:druid][:historical][:port] = 8082
default[:druid][:historical][:mx] = (node[:memory][:total].to_i/1024 - node[:druid][:processing][:memory] - node[:druid][:coordinator][:mx].to_i - 2048).ceil
default[:druid][:historical][:dm] = node[:druid][:processing][:memory].ceil

# Broker Services
default[:druid][:broker][:port] = 8080
default[:druid][:broker][:mx] = (node[:memory][:total].to_i/1024 - node[:druid][:processing][:memory] - node[:druid][:coordinator][:mx].to_i - 2048).ceil
default[:druid][:broker][:dm] = node[:druid][:processing][:memory].ceil
default[:druid][:broker][:cache_size_in_bytes] = 42949672960
default[:druid][:broker][:connections] = 20
default[:druid][:broker][:timeout] = "PT10M"
default[:druid][:broker][:balancer] = "connectionCount"

# Realtime Services
default[:druid][:realtime][:port] = 8083
default[:druid][:realtime][:mx] = 12 * 1024
default[:druid][:realtime][:dm] = 12 * 1024
default[:druid][:realtime][:partition] = IPAddr.new(node[:ipaddress]).to_i & (2**31-1)
