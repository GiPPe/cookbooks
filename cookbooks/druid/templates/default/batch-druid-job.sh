#!/bin/bash

job_file=$1

(
  flock -n 42 || exit 1

  # Set classpath
  CLASSPATH="$(find /var/app/druid/current/services/target/druid-services-*-selfcontained.jar)"
  CLASSPATH+=":$(find /var/app/druid/current/hdfs-storage/target/druid-hdfs-storage-*.jar)"
  CLASSPATH+=":$(<%= "#{node[:druid][:hadoop][:path]}/hadoop" %> classpath)"

  echo BATCH_IMPORT $job_file
  java -Xmx256m -Duser.timezone=UTC -Dfile.encoding=UTF-8 -classpath $CLASSPATH io.druid.cli.Main index hadoop $job_file
  sleep 600 # wait for cluster to distribute
  rm $job_file # might have been regenerated
) 42<$job_file
