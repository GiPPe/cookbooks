# Configuration File For Chef (chef-client)

node_name "<%= node[:fqdn] %>"
chef_server_url "<%= node[:chef][:client][:server_url] %>"

log_location STDOUT
verbose_logging false
enable_reporting false

file_cache_path "/var/lib/chef/cache"
file_backup_path "/var/lib/chef/backup"

Ohai::Config[:plugin_path] = [<%= node[:ohai][:plugin_path].inspect %>]

ssl_verify_mode :verify_none
verify_api_cert false

class Chef::Client
  def check_ssl_config
    # do nothing
  end
end
