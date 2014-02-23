include_recipe "java"

package "sys-cluster/hadoop"
package "dev-lang/apache-pig-bin"

package "app-arch/snappy"

link "/opt/hadoop/lib/native/Linux-amd64-64/libsnappy.so" do
  to "/usr/lib64/libsnappy.so"
end

%w(
  /var/lib/hadoop
  /var/log/hadoop
  /var/run/hadoop
).each do |dir|
  directory dir do
    owner "hadoop"
    group "hadoop"
    mode "0775"
  end
end

directory "/opt/hadoop/logs" do
  action :delete
  recursive true
  only_if { File.directory?("/opt/hadoop/logs") }
end

link "/opt/hadoop/logs" do
  to "/var/log/hadoop"
end

systemd_unit "hadoop@.service"

%w(
  core-site.xml
  hadoop-env.sh
  hdfs-site.xml
  log4j.properties
  mapred-site.xml
  fair-scheduler.xml
).each do |f|
  template "/opt/hadoop/conf/#{f}" do
    source f
    owner "root"
    group "root"
    mode "0644"
    variables({
      job_tracker: hadoop_jobtracker,
      name_node: hadoop_namenode,
    })
  end
end

file "/opt/hadoop/conf/hadoop-metrics2.properties" do
  action :delete
end

template "/opt/hadoop/conf/topology.sh" do
  source "topology.sh"
  owner "root"
  group "hadoop"
  mode "0554"
end

template "/opt/hadoop/conf/topology.data" do
  source "topology.data"
  owner "root"
  group "hadoop"
  mode "0644"
end

directory node[:hadoop][:tmp_dir] do
  owner "hadoop"
  group "hadoop"
  mode "0777"
  recursive true
end

directory node[:hadoop][:java_tmp] do
  owner "hadoop"
  group "hadoop"
  mode "0777"
  recursive true
end

nagios_plugin "check_hdfs" do
  source "check_hdfs.rb"
end

include_recipe "splunk::hadoop-ops" if splunk_forwarder?
