include_recipe "kafka"

template "/var/app/kafka/bin/migration.sh" do
  source "migration.sh"
  owner "root"
  group "kafka"
  mode "0650"
  notifies :restart, "service[kafka-migration]"
end

template "/etc/kafka/migration_consumer.properties" do
  source "migration_consumer.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka-migration]"
end

template "/etc/kafka/migration_producer.properties" do
  source "migration_producer.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka-migration]"
end

systemd_unit "kafka-migration.service"

service "kafka-migration" do
  action [:enable, :start]
end
