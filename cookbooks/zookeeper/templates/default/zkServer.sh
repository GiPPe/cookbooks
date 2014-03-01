#!/bin/bash

# JVM options
JVM_OPTS="-Dcom.sun.management.jmxremote.port=17000"
JVM_OPTS+=" -Dcom.sun.management.jmxremote.authenticate=false"
JVM_OPTS+=" -Dcom.sun.management.jmxremote.ssl=false"
JVM_OPTS+=" -Xmx16g"
JVM_OPTS+=" -server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC"

# zookeeper files
MAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"
CONFIG="/opt/zookeeper/conf/zoo.cfg"

# build the classpath
INSTALL_DIR=/opt/zookeeper
CLASSPATH="${INSTALL_DIR}/conf:${CLASSPATH}"

for i in ${INSTALL_DIR}/zookeeper-*.jar; do
  CLASSPATH="${i}:${CLASSPATH}"
done

for i in ${INSTALL_DIR}/lib/*.jar; do
  CLASSPATH="${i}:${CLASSPATH}"
done

exec /usr/bin/java $JVM_OPTS -cp $CLASSPATH $MAIN $CONFIG
