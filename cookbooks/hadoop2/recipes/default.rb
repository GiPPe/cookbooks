include_recipe "java"

package "app-arch/snappy"
package "dev-libs/protobuf"
package "dev-java/ant-core"

node.default[:hadoop2][:cluster] = node.cluster_name
node.default[:hadoop2][:zk][:cluster] = node.cluster_name

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
  not_if do
    File.exists?(release_dir)
  end

  command "/bin/bash -l -c 'mvn clean package -Pdist,native -Drequire.snappy -DskipTests'"
  cwd src_dir
  user "hadoop2"
  group "hadoop2"
end

link "/var/app/hadoop2/current" do
  to release_dir
end

template "#{release_dir}/libexec/hadoop-layout.sh" do
  source "hadoop-layout.sh"
  owner "root"
  group "hadoop2"
  mode "0755"
end

execute "remove-local-etc" do
 only_if do
   File.exists?("#{release_dir}/etc")
 end

 command "rm -rf #{release_dir}/etc"
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
