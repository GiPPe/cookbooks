#!/bin/bash

JAVA_HEAP_MAX=-Xmx${PIG_HEAPSIZE-1000}m

if [ -z $PIG_NO_DEFAULT_JARS ]; then
  unset PIG_DEFAULT_JARS
  for JAR in /var/app/hadoop2/pig/contrib/*.jar; do
    PIG_DEFAULT_JARS+=${PIG_DEFAULT_JARS:+":"}$JAR
  done
  PIG_OPTS+=" -Dpig.additional.jars=$PIG_DEFAULT_JARS"
  echo "Adding$PIG_OPTS"
  echo "Set PIG_NO_DEFAULT_JARS to omit default jars"
fi

PIG_JAR=$(find /var/app/hadoop2/pig/pig-<%= node[:hadoop2][:pig][:version] %>-src/build/pig*-withouthadoop.jar)
export HADOOP_CLASSPATH=/etc/hadoop2:/etc/java-config-2/current-system-vm/lib/tools.jar:$PIG_JAR
export HADOOP_OPTS="$JAVA_HEAP_MAX $PIG_OPTS $HADOOP_OPTS"

exec /var/app/hadoop2/current/bin/hadoop jar $PIG_JAR $@
