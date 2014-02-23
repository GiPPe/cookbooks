# Usage

On client nodes `recipe[mysql]` will install the MySQL client libraries and
development headers.

On server nodes `recipe[mysql::server]` will install and preseed a MySQL server
instance with a random root password and the usual `mysql_install_db` steps.
Additionally the `mysql::server` recipe will install configuration files for
syslog-ng and nagios.

# Attributes

The MySQL server supports a vast amount of configuration settings which cannot
be discussed in detail here. The most important settings are supported through
the following attributes. Where applicable best practice guidelines and
external resources are mentioned to help in optimizing server performance.

## Startup & Security

`mysql[:server][:startup_timeout] = 900`
  : This setting (in seconds) should be high enough to allow InnoDB to do a full
  checkpoint recovery. 900 is the default used in the upstream RPM startup
  scripts. 30 seconds should be sufficent if you just have a small database.
  After the core startup is done, we wait this long for the UNIX socket to
  appear.

`mysql[:server][:startup_early_timeout] = 1000`
  : This is how long, in milliseconds, we wait for pidfile to be created, early
  in the startup.

`mysql[:server][:stop_timeout] = 120`
  : This setting (in seconds) should be high enough to allow any pages in memory
  to be flushed to disk.

`mysql[:server][:skip_networking] = false`
  : Do not listen for TCP/IP connections at all. All interaction with mysqld must
  be made using Unix socket files. This option is highly recommended for
  systems where only local clients are permitted.

`mysql[:server][:bind_address] = "127.0.0.1"`
  : The IP address to bind to. Only one address can be selected. If no address or
  0.0.0.0 is specified, the server listens on all interfaces.

## Replication & Binary Log

`mysql[:server][:server_id] = IPAddr.new(node[:ipaddress]).to_i`
  : This option is common to both master and slave replication servers, and is
  used in replication to enable master and slave servers to identify themselves
  uniquely.

  : On the master and each slave, you must use the `server-id` option to
  establish a unique replication ID in the range from 1 to 232 - 1. Unique
  means that each ID must be different from every other ID in use by any other
  replication master or slave.

  : The default value is calculated by the primary IP address to provide a unique
  value out-of-the-box.

`mysql[:server][:slave_enabled] = false`
  : Enable MySQL slave support. This will enable the binary log (`log_bin =
  true`) and the relay log (`relay_log = true`). It will also register slave
  health checks with Nagios (see below).

`mysql[:server][:log_bin] = false`
  : Enable binary logging. The server logs all statements that change data to the
  binary log, which is used for backup and replication.

`mysql[:server][:sync_binlog] = "0"`
  : If the value of this variable is greater than 0, the MySQL server
  synchronizes its binary log to disk (using fdatasync()) after every
  sync\_binlog writes to the binary log. There is one write to the binary log
  per statement if autocommit is enabled, and one write per transaction
  otherwise.

  : The default value of sync\_binlog is 0, which does no synchronizing to disk
  -- in this case, the server relies on the operating system to flush the
  binary log's contents from to time as for any other file.

  : A value of 1 is the safest choice because in the event of a crash you lose at
  most one statement or transaction from the binary log. However, it is also
  the slowest choice (unless the disk has a battery-backed cache, which makes
  synchronization very fast).

`mysql[:server][:relay_log] = false`
  : The relay log, like the binary log, consists of a set of numbered files
  containing events that describe database changes, and an index file that
  contains the names of all used relay log files.

  : A slave server creates a new relay log file under the following conditions:

    * Each time the I/O thread starts.

    * When the logs are flushed; for example, with `FLUSH LOGS` or
      `mysqladmin flush-logs`.

    * When the size of the current relay log file becomes too large,
      determined as follows:

      * If the value of `max_relay_log_size` is greater than 0, that is the
        maximum relay log file size.

      * If the value of `max_relay_log_size` is 0, `max_binlog_size`
        determines the maximum relay log file size.

  : The SQL thread automatically deletes each relay log file as soon as it has
  executed all events in the file and no longer needs it. There is no explicit
  mechanism for deleting relay logs because the SQL thread takes care of doing
  so. However, `FLUSH LOGS` rotates relay logs, which influences when the SQL
  thread deletes them.

`mysql[:server][:expire_logs_days] = 14`
  : The number of days for automatic binary log file removal. A value of 0 means
  "no automatic removal".

`mysql[:server][:log_slave_updates] = false`
  : Normally, a slave does not log to its own binary log any updates that are
  received from a master server. This option tells the slave to log the updates
  performed by its SQL thread to its own binary log. For this option to have
  any effect, the slave must also be started with the `log-bin` option to
  enable binary logging. `log-slave-updates` is used when you want to chain
  replication servers.

`mysql[:server][:replicate_do_db] = false`
  : Tells the slave SQL thread to restrict replication to the specified array of
  databases. The effects of this option depend on whether statement-based or
  row-based replication is in use.

  : See the [MySQL manual][replicate_do_db] for details.

[replicate_do_db]: http://dev.mysql.com/doc/refman/5.1/en/replication-options-slave.html#option_mysqld_replicate-do-db

`mysql[:server][:replicate_do_table] = false`
  : Tells the slave SQL thread to restrict replication to the specified array of
  tables. This works for both cross-database updates and default database
  updates.

`mysql[:server][:slave_transaction_retries] = 10`
  : If a replication slave SQL thread fails to execute a transaction because of
  an InnoDB deadlock or because the transaction's execution time exceeded
  InnoDB's `innodb_lock_wait_timeout`, it automatically retries
  `slave_transaction_retries` times before stopping with an error.

`mysql[:server][:auto_increment_increment] = 1`
  : `auto_increment_increment` and `auto_increment_offset` are intended for use with
  master-to-master replication, and can be used to control the operation of
  `AUTO_INCREMENT` columns.

`mysql[:server][:auto_increment_offset] = 1`
  : `auto_increment_increment` and `auto_increment_offset` are intended for use with
  master-to-master replication, and can be used to control the operation of
  `AUTO_INCREMENT` columns.

  : See the [MySQL manual][auto_increment_increment] for details.

[auto_increment_increment]: http://dev.mysql.com/doc/refman/5.1/en/replication-options-master.html#sysvar_auto_increment_increment

## General Performance Options

`mysql[:server][:open_files_limit] = "4096"`
  : Changes the number of file descriptors available to mysqld. You should try
  increasing the value of this option if mysqld gives you the error `Too many
  open files`. mysqld uses the option value to reserve descriptors with
  `setrlimit()`. If the requested number of file descriptors cannot be
  allocated, mysqld writes a warning to the error log.

  : The `table_open_cache` and `max_connections` system variables affect the
  maximum number of files the server keeps open.  You must also reserve some
  extra file descriptors for temporary tables and files.

`mysql[:server][:table_open_cache] = "1024"`
  : The number of open tables for all threads. Increasing this value increases
  the number of file descriptors that mysqld requires. You can check whether
  you need to increase the table cache by checking the `Opened_tables` status
  variable. If the value of `Opened_tables` is large and you do not use
  `FLUSH TABLES` often (which just forces all tables to be closed and
  reopened), then you should increase the value of the `table_open_cache`
  variable.

  : For example, for 200 concurrent running connections, you should have a table
  cache size of at least 200 * N, where N is the maximum number of tables per
  join in any of the queries which you execute.

`mysql[:server][:table_definition_cache] = "4096"`
  : The number of table definitions that can be stored in the definition cache.
  If you use a large number of tables, you can create a large table definition
  cache to speed up opening of tables. The table definition cache takes less
  space and does not use file descriptors, unlike the normal table cache.

`mysql[:server][:thread_cache_size] = "16"`
  : How many threads the server should cache for reuse. When a client
  disconnects, the client's threads are put in the cache if there are fewer
  than thread_cache_size threads there. Requests for threads are satisfied by
  reusing threads taken from the cache if possible, and only when the cache is
  empty is a new thread created.

  : This variable can be increased to improve performance if you have a lot of
  new connections. Normally, this does not provide a notable performance
  improvement if you have a good thread implementation. However, if your server
  sees hundreds of connections per second you should normally set
  thread_cache_size high enough so that most new connections use cached
  threads.

  : By examining the difference between the `Connections` and `Threads_created`
  status variables, you can see how efficient the thread cache is.

`mysql[:server][:tmp_table_size] = "64M"`
  : The maximum size of internal in-memory temporary tables. (The actual limit is
  determined as the minimum of `tmp_table_size` and `max_heap_table_size`.)
  If an in-memory temporary table exceeds the limit, MySQL automatically
  converts it to an on-disk `MyISAM` table. Increase the value of
  `tmp_table_size` if you do many advanced `GROUP BY` queries and you have
  lots of memory.

`mysql[:server][:max_heap_table_size] = "64M"`
  : This variable sets the maximum size to which user-created `MEMORY` tables
  are permitted to grow. The value of the variable is used to calculate
  `MEMORY` table `MAX_ROWS` values.

  : This variable is automatically increased to at least `tmp_table_size` and
  should only be set manually if required for `MEMORY` tables.

`mysql[:server][:group_concat_max_len] = "1024"`
  : The maximum permitted result length in bytes for the `GROUP_CONCAT()`
  function.

## Client Connection Optimization

`mysql[:server][:max_connections] = "128"`
  : The maximum permitted number of simultaneous client connections. Increasing
  this value increases the number of file descriptors that mysqld requires. See
  `open_files_limit` above for more information.

`mysql[:server][:max_allowed_packet] = "16M"`
  : The maximum size of one packet or any generated/intermediate string.

  : The packet message buffer is initialized to `net_buffer_length` bytes, but can
  grow up to `max_allowed_packet` bytes when needed.

  : You must increase this value if you are using large BLOB columns or long
  strings. It should be as big as the largest BLOB you want to use. The
  protocol limit for `max_allowed_packet` is 1GB. The value should be a
  multiple of 1024; nonmultiples are rounded down to the nearest multiple.

`mysql[:server][:wait_timeout] = "28800"`
  : The number of seconds the server waits for activity on a noninteractive
  connection before closing it. This timeout applies only to TCP/IP and Unix
  socket file connections, not to connections made using named pipes, or shared
  memory.

`mysql[:server][:connect_timeout] = "10"`
  : The number of seconds that the mysqld server waits for a connect packet
  before responding with `Bad handshake`.

## Key Buffer Optimization

`mysql[:server][:key_buffer_size] = "64M"`
  : Index blocks for MyISAM tables are buffered and are shared by all threads.
  `key_buffer_size` is the size of the buffer used for index blocks. The key
  buffer is also known as the key cache.

  : You can increase the value to get better index handling for all reads and
  multiple writes; on a system whose primary function is to run MySQL using the
  MyISAM storage engine, 25% of the machine's total memory is an acceptable
  value for this variable. However, you should be aware that, if you make the
  value too large (for example, more than 50% of the machine's total memory),
  your system might start to page and become extremely slow. This is because
  MySQL relies on the operating system to perform file system caching for data
  reads, so you must leave some room for the file system cache. You should also
  consider the memory requirements of any other storage engines that you may be
  using in addition to MyISAM.

  : See the [MySQL manual][key_buffer_size] for details.

[key_buffer_size]: http://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html#sysvar_key_buffer_size

## Query Cache Optimization

`mysql[:server][:query_cache_size] = "128M"`
  : The amount of memory allocated for caching query results.  The permissible
  values are multiples of 1024; other values are rounded down to the nearest
  multiple.

`mysql[:server][:query_cache_type] = 1`
  : Set the query cache type. Possible values are:

    * 0 - Do not cache results in or retrieve results from the query cache.
    * 1 - Cache all cacheable query results except for those that begin with
      `SELECT SQL_NO_CACHE`.
    * 2 - Cache results only for cacheable queries that begin with `SELECT
      SQL_CACHE`.

`mysql[:server][:query_cache_limit] = "4M"`
  : Do not cache results that are larger than this number of bytes.

## Sort Optimization

`mysql[:server][:sort_buffer_size] = "4M"`
  : Each session that needs to do a sort allocates a buffer of this size.
  `sort_buffer_size` is not specific to any storage engine and applies in a
  general manner for optimization.

  : If you see many `Sort_merge_passes` per second in `SHOW GLOBAL STATUS`
  output, you can consider increasing the `sort_buffer_size` value to speed
  up `ORDER BY` or `GROUP BY` operations that cannot be improved with query
  optimization or improved indexing. The entire buffer is allocated even if it
  is not all needed, so setting it larger than required globally will slow down
  most queries that sort.

  : See the [MySQL manual][sort_buffer_size] for details.

[sort_buffer_size]: http://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html#sysvar_sort_buffer_size

`mysql[:server][:read_buffer_size] = "1M"`
  : Each thread that does a sequential scan allocates a buffer of this size (in
  bytes) for each table it scans. If you do many sequential scans, you might
  want to increase this value, which defaults to 131072. The value of this
  variable should be a multiple of 4KB. If it is set to a value that is not a
  multiple of 4KB, its value will be rounded down to the nearest multiple of
  4KB.

`mysql[:server][:read_rnd_buffer_size] = "512K"`
  : When reading rows in sorted order following a key-sorting operation, the rows
  are read through this buffer to avoid disk seeks.  Setting the variable to a
  large value can improve `ORDER BY` performance by a lot. However, this is a
  buffer allocated for each client, so you should not set the global variable
  to a large value. Instead, change the session variable only from within those
  clients that need to run large queries.

`mysql[:server][:myisam_sort_buffer_size] = "64M"`
  : The size of the buffer that is allocated when sorting MyISAM indexes during a
  `REPAIR TABLE` or when creating indexes with `CREATE INDEX` or `ALTER
  TABLE`.

## Join Optimization

`mysql[:server][:join_buffer_size] = "2M"`
  : The minimum size of the buffer that is used for plain index scans, range
  index scans, and joins that do not use indexes and thus perform full table
  scans. Normally, the best way to get fast joins is to add indexes. Increase
  the value of `join_buffer_size` to get a faster full join when adding
  indexes is not possible. One join buffer is allocated for each full join
  between two tables. For a complex join between several tables for which
  indexes are not used, multiple join buffers might be necessary.

  : There is no gain from setting the buffer larger than required to hold each
  matching row, and all joins allocate at least the minimum size, so use
  caution in setting this variable to a large value globally. It is better to
  keep the global setting small and change to a larger setting only in sessions
  that are doing large joins.  Memory allocation time can cause substantial
  performance drops if the global size is larger than needed by most queries
  that use it.

## InnoDB Options

`mysql[:server][:innodb_file_per_table] = true`
  : If `innodb_file_per_table` is enabled, InnoDB creates each new table using
  its own `.ibd` file for storing data and indexes, rather than in the shared
  tablespace.

`mysql[:server][:innodb_buffer_pool_size] = "512M"`
  : The size in bytes of the memory buffer InnoDB uses to cache data and indexes
  of its tables.

  : The larger you set this value, the less disk I/O is needed to access data in
  tables. On a dedicated database server, you may set this to up to 80% of the
  machine physical memory size. Be prepared to scale back this value if these
  other issues occur:

    * Competition for physical memory might cause paging in the operating
      system.

    * InnoDB reserves additional memory for buffers and control structures, so
      that the total allocated space is approximately 10% greater than the
      specified size.

    * The time to initialize the buffer pool is roughly proportional to its
      size. On large installations, this initialization time may be significant.

`mysql[:server][:innodb_log_file_size] = "256M"`
  : The size in bytes of each log file in a log group. The combined size of log
  files must be less than 4GB. Sensible values range from 1MB to 1/N-th of the
  size of the buffer pool, where N is the number of log files in the group
  (default: 2). The larger the value, the less checkpoint flush activity is
  needed in the buffer pool, saving disk I/O. But larger log files also mean
  that recovery is slower in case of a crash.

  : See also:

    * [How to calculate a good InnoDB log file size](http://www.mysqlperformanceblog.com/2008/11/21/how-to-calculate-a-good-innodb-log-file-size/)
    * [Choosing proper innodb_log_file_size](http://www.mysqlperformanceblog.com/2006/07/03/choosing-proper-innodb_log_file_size/)

`mysql[:server][:innodb_log_buffer_size] = "1M"`
  : The size in bytes of the buffer that InnoDB uses to write to the log files on
  disk. Sensible values range from 1MB to 8MB. A large log buffer enables large
  transactions to run without a need to write the log to disk before the
  transactions commit. Thus, if you have big transactions, making the log
  buffer larger saves disk I/O.

`mysql[:server][:innodb_flush_log_at_trx_commit] = "1"`
  : If the value of `innodb_flush_log_at_trx_commit` is 0, the log buffer is
  written out to the log file once per second and the flush to disk operation
  is performed on the log file, but nothing is done at a transaction commit.

  : When the value is 1, the log buffer is written out to the log file at each
  transaction commit and the flush to disk operation is performed on the log
  file.

  : When the value is 2, the log buffer is written out to the file at each
  commit, but the flush to disk operation is not performed on it.  However, the
  flushing on the log file takes place once per second also when the value is
  2. Note that the once-per-second flushing is not 100% guaranteed to happen
  every second, due to process scheduling issues.

  : The default value of 1 is the value required for ACID compliance. You can
  achieve better performance by setting the value different from 1, but then
  you can lose at most one second worth of transactions in a crash. With a
  value of 0, any mysqld process crash can erase the last second of
  transactions. With a value of 2, then only an operating system crash or a
  power outage can erase the last second of transactions. However, InnoDB's
  crash recovery is not affected and thus crash recovery does work regardless
  of the value.

  : For the greatest possible durability and consistency in a replication setup
  using InnoDB with transactions, use `innodb_flush_log_at_trx_commit = 1` and
  `sync_binlog = 1` on the master server.

`mysql[:server][:innodb_thread_concurrency] = node[:cpu][:total] * 2 + 1`
  : InnoDB tries to keep the number of operating system threads concurrently
  inside InnoDB less than or equal to the limit given by this variable. Once
  the number of threads reaches this limit, additional threads are placed into
  a wait state within a FIFO queue for execution. Threads waiting for locks are
  not counted in the number of concurrently executing threads.

  : The correct value for this variable is dependent on environment and workload.
  You will need to try a range of different values to determine what value
  works for your applications. A recommended value is 2 times the number of
  CPUs plus the number of disks.

  : You can disable thread concurrency checking by setting the value to 0.
  Disabling thread concurrency checking enables InnoDB to create as many
  threads as it needs.

`mysql[:server][:innodb_lock_wait_timeout] = "50"`
  : The timeout in seconds an InnoDB transaction may wait for a row lock before
  giving up. The default value is 50 seconds. A transaction that tries to
  access a row that is locked by another InnoDB transaction will hang for at
  most this many seconds before issuing the following error:

  : `ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction`

  : When a lock wait timeout occurs, the current statement is not executed. The
  current transaction is not rolled back.

## Fulltext Search Options

`mysql[:server][:ft_min_word_len] = 4`
  : The minimum length of the word to be included in a FULLTEXT index.
  `FULLTEXT` indexes must be rebuilt after changing this variable. Use `REPAIR
  TABLE tbl_name QUICK`.

## Miscellaneous Options

`mysql[:server][:default_storage_engine] = "MyISAM"`
  : Set the default storage engine (table type) for tables.

## Nagios

`mysql[:server][:detailed_monitoring] = false`
  : Enable more detailed nagios service checks which mostly depend on the
  application running queries and creating indexes etc. Since these metrics may
  not be optimized by the Operations team alone, these are disabled by default.

`mysql[:server][:nagios][...][:enabled] = ...`
`mysql[:server][:nagios][...][:warning] = ...`
`mysql[:server][:nagios][...][:critical] = ...`
`mysql[:server][:nagios][...][:check_interval] = ...`
`mysql[:server][:nagios][...][:notification_interval] = ...`
  : Configuration of nagios service check thresholds and intervals. For a
  detailed list of available service checks and their default thresholds and
  intervals see the `attributes/server.rb` file in the `mysql` cookbook.


# Resources & Providers

The cookbook contains the following resources which can be used to manage
databases and users through calls to the MySQL API. These resources only work
on nodes that have been deployed with the `mysql::server` recipe (see below).

## MySQL User

Configure MySQL users and possibly generate a random password for it.

### Actions

`create`
  : create the user if it does not exist. (default)

`delete`
  : delete the specified user.

### Attributes

`host = "localhost"`
  : The host this user is allowed to connect from.

`password = nil`
  : The password for the specified user. `nil` will generate a random password.

`force_password = false`
  : Set the specified password even if the user already has a password.


## MySQL Grants

Configure MySQL grants/permissions for existing users.

### Actions

`create`
  : create the permissions if it does not exist. (default)

`delete`
  : delete the specified permissions.

### Attributes

`privileges`
  : ..

`database`
  : ..

`user`
  : ..

`user_host`
  : ..

`grant_option`
  : ..


## MySQL Database

Creates MySQL databases and users if the database owner does not exist.

### Actions

`create`
  : create the database if it does not exist. (default)

`delete`
  : delete the specified database.

### Attributes

`owner`
  : ..

`owner_host`
  : ..


# Log files

The MySQL server does not support logging to syslog. Therefore the
`mysql::server` recipe will install a syslog-ng configuration to poll
`/var/log/mysql/mysqld.err` and `/var/log/mysql/slow-queries.log` in case a
central syslog server exists.

Additionally a logrotate configuration file is installed that can be used to
send a report of slow queries created automatically from `slow-queries.log`
by `mk-query-digest` from the maatkit distribution. This report is
automatically enabled when `mysql[:server][:long_query_time]` is greater than
0. The report is sent to the address specified in the `contacts[:mysql]`
attribute (default: `root`).

# Nagios Service Checks

The `mysql::server` recipe will register the following nagios service checks
with the chef server. Most service checks are based on `check_mysql_health`
by ConSol Labs. For details see the `check_mysql_health project page
<http://labs.consol.de/lang/en/nagios/check_mysql_health/>`_.

**MYSQL**
  : Checks if the mysqld process is running

**MYSQL-CTIME**
  : Determines how long connection establishment and login take

**MYSQL-CONNS**
  : Number of open connections

**MYSQL-TCHIT**
  : Hitrate in the Thread-Cache

**MYSQL-QCHIT**
  : Hitrate in the Query Cache

**MYSQL-QCLOW**
  : Displacement out of the Query Cache due to memory shortness

**MYSQL-SLOW**
  : Rate of queries that were detected as 'slow'

**MYSQL-LONG**
  : Sum of processes that are runnning longer than 1 minute

**MYSQL-TABHIT**
  : Hitrate in the Table-Cache

**MYSQL-LOCK**
  : Rate of failed table locks

**MYSQL-INDEX**
  : Sum of the Index-Utilization (in contrast to Full Table Scans)

**MYSQL-TMPTAB**
  : Percent of the temporary tables that were created on the disk instead in
  memory

**MYSQL-KCHIT**
  : Hitrate in the Myisam Key Cache

**MYSQL-BPHIT**
  : Hitrate in the InnoDB Buffer Pool

**MYSQL-BPWAIT**
  : Rate of the InnoDB Buffer Pool Waits

**MYSQL-LOGWAIT**
  : Rate of the InnoDB Log Waits

**MYSQL-SLAVEIO**
  : Checks if the IO-Thread of the Slave-DB is running

**MYSQL-SLAVESQL**
  : Checks if the SQL-Thread of the Slave-DB is running

**MYSQL-SLAVELAG**
  : Delay between Master and Slave
