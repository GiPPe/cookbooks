role = JSON.load(File.read(File.expand_path("../../roles/base.json", __FILE__)))
chef_domain = role['default_attributes']['chef_domain'] rescue "localhost"

chef_server_url "https://chef.#{chef_domain}"

# do not change anything below here
chef_repo_path File.expand_path(File.join(File.dirname(__FILE__), ".."))

if Process.euid == 0
  chef_root = "/var/lib/chef"
  node_name %x(hostname -f).chomp
else
  chef_root = File.expand_path("~/.chef")
  user_file = File.join(chef_repo_path, ".user")
  if File.readable?(user_file)
    node_name File.read(user_file).chomp
  else
    node_name %x(whoami).chomp
  end
end

cookbook_path [
  "#{chef_repo_path}/cookbooks",
  "#{chef_repo_path}/site-cookbooks",
]

if ENV["CHEF_ZERO"]
  node_path "#{chef_repo_path}/.vagrant/nodes"
end

script_path "#{chef_repo_path}/scripts"

if File.exist?("#{chef_repo_path}/.chef/client.pem")
  client_key "#{chef_repo_path}/.chef/client.pem"
  validation_client_name node_name
  validation_key client_key
end

syntax_check_cache_path "#{chef_repo_path}/.chef/checksums"

file_cache_path "#{chef_root}/cache/files"
file_backup_path "#{chef_root}/backup"

Ohai::Config[:plugin_path] = ["#{chef_repo_path}/cookbooks/ohai/files/default/plugins"]

ssl_verify_mode :verify_none
verify_api_cert false

class Chef::Client
  def check_ssl_config
    # do nothing
  end
end
