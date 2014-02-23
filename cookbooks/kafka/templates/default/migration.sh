#!/bin/bash

KAFKA_HEAP_OPTS="-Xmx8G"
KAFKA_07_JAR="/var/app/kafka/current/system_test/migration_tool_testsuite/0.7/lib/kafka-0.7.0.jar"
ZKCLIENT_JAR="/var/app/kafka/current/system_test/migration_tool_testsuite/0.7/lib/zkclient-0.1.jar"
NUM_STREAMS=<%= node[:kafka][:migration][:streams] %>
NUM_PRODUCERS=<%= node[:kafka][:migration][:producers] %>
CONSUMER_CONF="/etc/kafka/migration_consumer.properties"
PRODUCER_CONF="/etc/kafka/migration_producer.properties"
WHITELIST="<%= node[:kafka][:migration][:whitelist] %>"

exec /var/app/kafka/current/bin/kafka-run-class.sh kafka.tools.KafkaMigrationTool --kafka.07.jar $KAFKA_07_JAR --zkclient.01.jar $ZKCLIENT_JAR --num.streams $NUM_STREAMS --num.producers $NUM_PRODUCERS --consumer.config=$CONSUMER_CONF --producer.config=$PRODUCER_CONF --whitelist=$WHITELIST
