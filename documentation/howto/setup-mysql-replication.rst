Setting Up MySQL Replication
============================

How to create a slave using XtraBackup
--------------------------------------

* setup:

  * existing servers: db1.local, db2.local

    * running live and **only InnoDB tables** (or you don't care about
      consistency in MyISAM tables)
    * db2.local is a slave of db1.local
    * snapshot will be taken on db2.local

  * new server: db3.local

* prepare db3.local to receive tar stream:

  * ``nc -l -p 9999 | tar xvi -C /var/lib/mysql.new``

* start InnoDB snapshot on db2.local:

  * ``innobackupex --slave-info --stream=tar ./ | nc db3.local 9999``

    * hit ``CTRL-C`` as soon as innobackupex says ``Completed OK`` to kill
      the nc connection.

  * it turned out that an additional "gzip --fast" is helpful on slower
    connections (100Mbit)

* start InnoDB recovery on db3.local:

  * ``innobackupex --apply-log /var/lib/mysql.new``
  * there's a parameter --use-memory which can help increase the speed of
    applying the logs, e.g by saying --use-memory 12G on a 24G RAM machine
    (defualt seems to be a mere 100M). however it slows down the shutdown
    process, because the buffer has to be flushed out at the end, so lower
    settings may be faster in total.

* stop MySQL on db3.local and switch to new snapshot:

  * ``/etc/init.d/mysql stop``
  * ``mv /var/lib/mysql /var/lib/mysql.old``
  * ``mv /var/lib/mysql.new /var/lib/mysql``
  * ``chown mysql:mysql -R /var/lib/mysql``
  * ``/etc/init.d/mysql start``

* setup replication on db3.local:

  * if db2.local should be the new master:

    * ``cat /var/lib/mysql/xtrabackup_binlog_info``

  * if db1.local should be the new master:

    * ``cat /var/lib/mysql/xtrabackup_slave_info``

  * ``mysql -e 'CHANGE MASTER TO ...'``

How to setup a new slave from an existing slave (the hard way)
--------------------------------------------------------------

* setup:

  * master: db1.local
  * existing slave: db2.local
  * new slave: db3.local

* create a replication user on db1.local:

  * ``%%GRANT REPLICATION SLAVE ON *.* TO 'replication'@'db3.local' IDENTIFIED BY 'sekrit'%%``

* lock all tables on db2.local:

  * ``FLUSH TABLES WITH READ LOCK``
  * **remember to leave the mysql shell open to hold the lock**
  * **TODO:** mysqldump --master-data=2 & --single-transaction for innodb

* remember the binary log position of db2.local:

  * ``SHOW SLAVE STATUS\G``

    * Exec_Master_Log_Pos
    * Master_Log_File

* copy the raw data files from db2.local to db3.local:

  * ``rsync -Wav /var/lib/mysql/mydb/ db3.local:/var/lib/mysql/mydb/``

* start mysqld on db3.local without a slave thread:

  * ``rm /var/lib/mysql/master.info``
  * ``/etc/init.d/mysql start``

* configure db3.local to use db1.local as master:

  * ``%%CHANGE MASTER TO MASTER_HOST = 'db1.local', MASTER_USER = 'replication', MASTER_PASSWORD = 'sekrit', MASTER_LOG_FILE = '<Master_Log_File>', MASTER_LOG_POS = <Exec_Master_Log_Pos>;%%``
  * ``START SLAVE;``

* check that everything works:

  * ``SHOW SLAVE STATUS\G``

    * Seconds_Behind_Master should be zero after a while
