include_recipe "hadoop2"

service "mapred@historyserver" do
  action [:enable, :start]
end
