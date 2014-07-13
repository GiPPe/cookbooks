include_recipe "java"

basename = ::File.basename(node[:confluence][:download_url], '.tar.gz')

tar_extract node[:confluence][:download_url] do
  target_dir "/opt"
  creates "/opt/#{basename}"
  user "root"
  group "root"
end

link "/opt/confluence" do
  to "/opt/#{basename}"
end

remote_file "/opt/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.26-bin.jar" do
  source "http://mirror.zenops.net/distfiles/mysql-connector-java-5.1.26-bin.jar"
  checksum "bea68038a00bd4f9ed07677de738703ec58ea2229e22c237d9b2fe497f2b8bc1"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/opt/confluence/conf/logging.properties" do
  source "logging.properties"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

template "/opt/confluence/conf/server.xml" do
  source "server.xml"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

template "/opt/confluence/confluence/WEB-INF/classes/confluence-init.properties" do
  source "confluence-init.properties"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

directory "/var/lib/confluence" do
  owner "root"
  group "root"
  mode "0750"
end

systemd_unit "confluence.service"

service "confluence" do
  action [:enable, :start]
end

include_recipe "nginx"

ssl_certificate "/etc/ssl/nginx/confluence" do
  cn node[:confluence][:certificate]
end

nginx_server "confluence" do
  template "nginx.conf"
end

shorewall_rule "confluence" do
  destport "http,https"
end

shorewall6_rule "confluence" do
  destport "http,https"
end

duply_backup "confluence" do
  source "/var/lib/confluence"
end
