include_recipe "java"

deploy_skeleton "kafka"

deploy_application "kafka" do
  repository node[:kafka][:git][:repository]
  revision node[:kafka][:git][:revision]

  before_symlink do
    execute "kafka-build" do
      command "#{release_path}/gradlew jar"
      cwd release_path
      user "kafka"
      group "kafka"
    end
  end
end

template "/var/app/kafka/current/config/log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

template "/var/app/kafka/current/config/tools-log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

if nagios_client?
  nagios_plugin "check_kafka_lag" do
    source "check_kafka_lag.rb"
  end

  nagios_plugin "check_kafka_partitioning" do
    source "check_kafka_partitioning.rb"
  end
end
