include_recipe "hadoop2"

service "hdfs@journalnode" do
  action [:enable, :start]
end
