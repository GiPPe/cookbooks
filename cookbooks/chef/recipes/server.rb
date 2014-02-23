remote_file "#{Chef::Config[:file_cache_path]}/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb" do
  source "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb"
end

dpkg_package "chef-server" do
  source "#{Chef::Config[:file_cache_path]}/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb"
  notifies :run, "execute[chef-server-ctl-reconfigure]"
end

execute "chef-server-ctl-reconfigure" do
  command "chef-server-ctl reconfigure"
end

shorewall_rule "chef-server" do
  destport "http,https"
end
