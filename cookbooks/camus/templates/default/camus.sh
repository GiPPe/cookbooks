#!/bin/bash

CLASSPATH="$(echo /var/app/camus/current/camus-liquidm/target/*selfcontained.jar):$(<%= node[:camus][:hadoop][:path]%>/hadoop classpath)"
exec /usr/bin/java -cp $CLASSPATH com.linkedin.camus.etl.kafka.CamusJob -P /etc/camus/camus.properties
