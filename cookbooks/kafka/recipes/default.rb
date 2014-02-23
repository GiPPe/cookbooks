include_recipe "java"

deploy_skeleton "kafka"

%w(
  /etc/kafka
).each do |dir|
  directory dir do
    owner "kafka"
    group "kafka"
    mode "0755"
  end
end

deploy_application "kafka" do
  repository node[:kafka][:git][:repository]
  revision node[:kafka][:git][:revision]

  before_symlink do
    execute "sbt-update" do
      command "#{release_path}/sbt update"
      cwd release_path
      user "kafka"
      group "kafka"
    end

    execute "sbt-package" do
      command "#{release_path}/sbt package"
      cwd release_path
      user "kafka"
      group "kafka"
    end

    execute "sbt-assembly-package-dependency" do
      command "#{release_path}/sbt assembly-package-dependency"
      cwd release_path
      user "kafka"
      group "kafka"
    end
  end
end

if nagios_client?
  nagios_plugin "check_kafka_lag" do
    source "check_kafka_lag.rb"
  end

  nagios_plugin "check_kafka_partitioning" do
    source "check_kafka_partitioning.rb"
  end
end
