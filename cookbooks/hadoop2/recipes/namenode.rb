include_recipe "hadoop2"

execute "hadoop-namenode-format" do
  command "/var/app/hadoop2/current/bin/hdfs namenode -format #{node[:hadoop2][:cluster]}"
  creates "/var/app/hadoop2/storage/namenode/current/VERSION"
  user "hadoop2"
  group "hadoop2"
end

service "hdfs@namenode" do
  action [:enable, :start]
end
