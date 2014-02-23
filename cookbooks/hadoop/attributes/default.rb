default[:hadoop][:rack_id] = "/default/rack"
default[:hadoop][:tmp_dir] = "/var/tmp/hadoop"
default[:hadoop][:java_tmp] = "/var/tmp/java"

default[:hadoop][:fs][:inmemory] = "2000"

default[:hadoop][:fs][:s3][:access_key] = ""
default[:hadoop][:fs][:s3][:secret_key] = ""

default[:hadoop][:dfs][:name_dir] = "/var/lib/hadoop/name"
default[:hadoop][:dfs][:data_dir] = "/var/lib/hadoop/data"

default[:hadoop][:dfs][:permissions] = false

default[:hadoop][:mapper][:tasks] = 4
default[:hadoop][:reducer][:tasks] = 3

default[:hadoop][:io][:sort][:factor] = "200"
default[:hadoop][:io][:sort][:mb] = "2000"
