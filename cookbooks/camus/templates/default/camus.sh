#!/bin/bash

CLASSPATH="$(echo /var/app/camus/current/camus-liquidm/target/*selfcontained.jar):$(/opt/hadoop/bin/hadoop classpath)"
exec /usr/bin/java -cp $CLASSPATH com.linkedin.camus.etl.kafka.CamusJob -P /etc/camus/camus.properties
