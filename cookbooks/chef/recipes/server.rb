source_url = "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.1.1-1_amd64.deb"
source_filename = File.basename(source_url)

remote_file "#{Chef::Config[:file_cache_path]}/#{source_filename}" do
  source source_url
end

dpkg_package "chef-server" do
  source "#{Chef::Config[:file_cache_path]}/#{source_filename}"
end

execute "chef-server-ctl-reconfigure" do
  command "chef-server-ctl reconfigure"
end

execute "chef-server-restart" do
  command "chef-server-ctl restart"
  action :nothing
end

ssl_certificate "/var/opt/chef-server/nginx/ca/#{node[:fqdn]}" do
  cn "wildcard.#{node[:chef_domain]}"
  notifies :run, "execute[chef-server-restart]"
end

shorewall_rule "chef-server" do
  destport "http,https"
end

cookbook_file "/opt/chef-server/bin/backup" do
  source "backup.sh"
  owner "root"
  group "root"
  mode "0755"
end

cron "chef-server-backup" do
  command "/opt/chef-server/bin/backup --backup"
  hour "3"
  minute "0"
end

duply_backup "chef-server" do
  source "/var/opt/chef-server/backup"
end
