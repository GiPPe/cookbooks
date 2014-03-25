source_url = "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.11-1.ubuntu.12.04_amd64.deb"
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

shorewall_rule "chef-server" do
  destport "http,https"
end
