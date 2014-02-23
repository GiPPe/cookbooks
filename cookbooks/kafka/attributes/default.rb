default[:kafka][:git][:repository] = "https://github.com/apache/kafka"
default[:kafka][:git][:revision] = "0.8"

default[:kafka][:storage] = "/var/app/kafka/storage"

default[:kafka][:zookeeper][:root] = "/kafka"

default[:kafka][:partition][:default] = 4
default[:kafka][:partition][:replication] = 1

default[:kafka][:log][:retention_hours] = 144

default[:kafka][:migration][:streams] = 8
default[:kafka][:migration][:producers] = 16
default[:kafka][:migration][:groupid] = "kafka-07-08-migration"
default[:kafka][:migration][:whitelist] = ".*"
default[:kafka][:migration][:compression] = 0
