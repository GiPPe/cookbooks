include_attribute "base"

default_unless[:contacts][:mysql] = "root@#{node[:fqdn]}"

# paths
default[:mysql][:server][:sharedstatedir] = "/usr/share/mysql"
default[:mysql][:server][:sysconfdir] = "/etc/mysql"
default[:mysql][:server][:libdir] = "/usr/lib/mysql"
default[:mysql][:server][:localstatedir] = "/var/lib/mysql"
default[:mysql][:server][:logdir] = "/var/log/mysql"
default[:mysql][:server][:rundir] = "/run/mysqld"
default[:mysql][:server][:includedir] = "/usr/include/mysql"
default[:mysql][:server][:datadir] = "/var/lib/mysql"
default[:mysql][:server][:tmpdir] = "/var/tmp"

# Startup & Security
default[:mysql][:server][:startup_timeout] = 900
default[:mysql][:server][:startup_early_timeout] = 1000
default[:mysql][:server][:stop_timeout] = 120
default[:mysql][:server][:skip_networking] = false
default[:mysql][:server][:bind_address] = "0.0.0.0"
default[:mysql][:server][:skip_innodb] = false

# Replication & Binary Log
default[:mysql][:server][:server_id] = IPAddr.new(node[:primary_ipaddress]).to_i
default[:mysql][:server][:slave_enabled] = false
default[:mysql][:server][:active_master] = false
default[:mysql][:server][:log_bin] = true
default[:mysql][:server][:sync_binlog] = "0"
default[:mysql][:server][:relay_log] = true
default[:mysql][:server][:expire_logs_days] = 14
default[:mysql][:server][:log_slave_updates] = false
default[:mysql][:server][:replicate_do_db] = false
default[:mysql][:server][:replicate_do_table] = false
default[:mysql][:server][:slave_transaction_retries] = 10
default[:mysql][:server][:auto_increment_increment] = 1
default[:mysql][:server][:auto_increment_offset] = 1
default[:mysql][:server][:binlog_format] = 'row'

# General Performance Options
default[:mysql][:server][:table_open_cache] = "1024"
default[:mysql][:server][:table_definition_cache] = 4 * node[:mysql][:server][:table_open_cache].to_i
default[:mysql][:server][:open_files_limit] = 3 * node[:mysql][:server][:table_open_cache].to_i
default[:mysql][:server][:tmp_table_size] = "64M"
default[:mysql][:server][:max_heap_table_size] = node[:mysql][:server][:tmp_table_size]
default[:mysql][:server][:group_concat_max_len] = "1024"

# Client Connection Optimization
default[:mysql][:server][:max_connections] = "128"
default[:mysql][:server][:thread_cache_size] = node[:mysql][:server][:max_connections]
default[:mysql][:server][:max_allowed_packet] = "16M"
default[:mysql][:server][:wait_timeout] = "28800"
default[:mysql][:server][:connect_timeout] = "10"

# Key Buffer Optimization
default[:mysql][:server][:key_buffer_size] = "64M"

# Query Cache Optimization
default[:mysql][:server][:query_cache_size] = "128M"
default[:mysql][:server][:query_cache_type] = 1
default[:mysql][:server][:query_cache_limit] = "4M"

if node[:mysql][:server][:query_cache_type] == 0
  default[:mysql][:server][:query_cache_size] = 0
end

# Sort Optimization
default[:mysql][:server][:sort_buffer_size] = "4M"
default[:mysql][:server][:read_buffer_size] = "1M"
default[:mysql][:server][:read_rnd_buffer_size] = "512K"
default[:mysql][:server][:myisam_sort_buffer_size] = "64M"

# Join Optimization
default[:mysql][:server][:join_buffer_size] = "2M"

# InnoDB Options
default[:mysql][:server][:innodb_file_per_table] = true
default[:mysql][:server][:innodb_data_home_dir] = "/var/lib/mysql"
default[:mysql][:server][:innodb_buffer_pool_size] = "512M"
default[:mysql][:server][:innodb_log_file_size] = "256M"
default[:mysql][:server][:innodb_log_buffer_size] = "1M"
default[:mysql][:server][:innodb_flush_log_at_trx_commit] = "1"
default[:mysql][:server][:innodb_thread_concurrency] = node[:cpu][:total] * 2 + 1
default[:mysql][:server][:innodb_lock_wait_timeout] = "50"

# Fulltext Search Options
default[:mysql][:server][:ft_min_word_len] = 4

# Miscellaneous Options
default[:mysql][:server][:default_storage_engine] = "MyISAM"

# backup
default[:mysql][:backupdir] = "/var/backup/mysql"
default[:mysql][:backups] = {}

# nagios
default[:mysql][:server][:detailed_monitoring] = false

{ # name          command               warn crit check note detailed
  :ctime    => %w(connection-time       1    5    1     15   0),
  :conns    => %w(threads-connected     0    0    1     15   0),
  :tchit    => %w(threadcache-hitrate   90:  80:  60    180  1),
  :qchit    => %w(qcache-hitrate        90:  80:  60    180  1),
  :qclow    => %w(qcache-lowmem-prunes  1    10   60    180  1),
  :long     => %w(long-running-procs    10   20   5     60   0),
  :tabhit   => %w(tablecache-hitrate    99:  95:  60    180  1),
  :lock     => %w(table-lock-contention 1    2    60    180  1),
  :index    => %w(index-usage           90:  80:  60    60   1),
  :tmptab   => %w(tmp-disk-tables       25   50   60    180  1),
  :kchit    => %w(keycache-hitrate      99:  95:  60    180  1),
  :bphit    => %w(bufferpool-hitrate    99:  95:  60    180  1),
  :bpwait   => %w(bufferpool-wait-free  1    10   60    180  1),
  :logwait  => %w(log-waits             1    10   60    180  1),
  :slaveio  => %w(slave-io-running      0    0    1     15   0),
  :slavesql => %w(slave-sql-running     0    0    1     15   0),
  :slavelag => %w(slave-lag             60   120  5     60   0),
}.each do |name, p|
  enabled = node[:mysql][:server][:detailed_monitoring] || p[5].to_i.zero?

  default[:mysql][:server][:nagios][name] = {
    :command => p[0],
    :warning => p[1],
    :critical => p[2],
    :check_interval => p[3].to_i,
    :notification_interval => p[4].to_i,
    :enabled => enabled,
  }
end

# calculate a bunch of thresholds from mysql attributes
default[:mysql][:server][:nagios][:conns][:warning] = (node[:mysql][:server][:max_connections].to_i * 0.80).to_i
default[:mysql][:server][:nagios][:conns][:critical] = (node[:mysql][:server][:max_connections].to_i * 0.95).to_i

if node[:mysql][:server][:detailed_monitoring]
  default[:mysql][:server][:nagios][:bphit][:enabled]   = node[:mysql][:server][:skip_innodb]
  default[:mysql][:server][:nagios][:bpwait][:enabled]  = node[:mysql][:server][:skip_innodb]
  default[:mysql][:server][:nagios][:logwait][:enabled] = node[:mysql][:server][:skip_innodb]
end

default[:mysql][:server][:nagios][:slaveio][:enabled]  = node[:mysql][:server][:slave_enabled]
default[:mysql][:server][:nagios][:slavesql][:enabled] = node[:mysql][:server][:slave_enabled]
default[:mysql][:server][:nagios][:slavelag][:enabled] = node[:mysql][:server][:slave_enabled]
