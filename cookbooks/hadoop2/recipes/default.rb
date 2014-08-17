include_recipe "java"

package "app-arch/snappy"
package "dev-libs/protobuf"
package "dev-java/ant-core"

deploy_skeleton "hadoop2"

%w(
  /etc/hadoop2
  /var/log/hadoop2
  /var/run/hadoop2
  /var/app/hadoop2/storage
  /var/app/hadoop2/storage/journalnode
  /var/app/hadoop2/storage/namenode
  /var/app/hadoop2/storage/datanode
  /var/app/hadoop2/storage/nodemanager
).each do |dir|
  directory dir do
    owner "hadoop2"
    group "root"
    mode "0775"
  end
end

[
  node[:hadoop2][:tmp_dir],
  node[:hadoop2][:java_tmp]
].each do |dir|
  directory dir do
    owner "hadoop2"
    group "root"
    mode "0777"
  end
end

%w(
  /var/app/hadoop2/storage/tmp
).each do |dir|
  directory dir do
    owner "hadoop2"
    group "root"
    mode "0777"
  end
end

%w{
  log4j.properties
  hdfs-site.xml
  core-site.xml
  yarn-site.xml
  topology.data
  mapred-site.xml
  pig.properties
}.each do |conf_file|
  template "/etc/hadoop2/#{conf_file}" do
    source conf_file
    owner "root"
    group "hadoop2"
    mode "0644"
    notifies :create, "ruby_block[hadoop-zk-chroot]"
  end
end

template "/etc/hadoop2/dfs.hosts.exclude" do
  source "dfs.hosts.exclude"
  owner "root"
  group "hadoop2"
  mode "0644"
end

systemd_unit "hdfs@.service"
systemd_unit "yarn@.service"
systemd_unit "mapred@.service"

src_tar = "http://www.us.apache.org/dist/hadoop/common/hadoop-#{node[:hadoop2][:version]}/hadoop-#{node[:hadoop2][:version]}-src.tar.gz"
src_dir = "/var/app/hadoop2/releases/hadoop-#{node[:hadoop2][:version]}-src"
release_dir = "#{src_dir}/hadoop-dist/target/hadoop-#{node[:hadoop2][:version]}"

tar_extract src_tar do
  target_dir "/var/app/hadoop2/releases"
  creates src_dir
  user "hadoop2"
  group "hadoop2"
end

execute "hadoop2-build" do
  command "/bin/bash -l -c 'mvn clean package -Pdist,native -Drequire.snappy -DskipTests'"
  user "hadoop2"
  group "hadoop2"
  cwd src_dir
  not_if { File.exists?(release_dir) }
end

template "#{release_dir}/libexec/hadoop-layout.sh" do
  source "hadoop-layout.sh"
  owner "root"
  group "hadoop2"
  mode "0755"
end

directory "#{release_dir}/etc" do
  action :delete
  recursive true
end

link "/var/app/hadoop2/current" do
  to release_dir
end

include_recipe "zookeeper::ruby"

ruby_block "hadoop-zk-chroot" do
  action :nothing
  block do
    Gem.clear_paths
    require 'zk'
    zk = ZK.new(zookeeper_connect('/hadoop2', node[:hadoop2][:zookeeper][:cluster]))
    [
      "/ha",
      "/ha/#{node[:hadoop2][:cluster]}",
      "/rmstore",
      "/rmstore/#{node[:hadoop2][:cluster]}",
    ].each do |path|
      zk.create(path, ignore: :node_exists)
    end
  end
end

