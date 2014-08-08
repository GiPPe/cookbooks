include_recipe "hadoop2"

service "hdfs@zkfc" do
  action [:enable, :start]
  only_if { hadoop2_namenodes.count > 1 }
end
