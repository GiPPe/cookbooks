include_recipe "hadoop2"

MAPRED_SERVICE = "historyserver"
RESTARTS_ON = %w{
}

service "mapred@#{MAPRED_SERVICE}" do
  action [:enable, :start]

  RESTARTS_ON.each do |conf_file|
    subscribes :restart, "template[/etc/hadoop2/#{conf_file}]"
  end
end
