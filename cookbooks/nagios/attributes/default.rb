default[:nagios][:server_name] = "nagios.#{node[:chef_domain]}"
default[:nagios][:certificate] = "wildcard.#{node[:chef_domain]}"
default[:nagios][:from_address] = "nagios@#{node[:fqdn]}"
default[:nagios][:nsca][:password] = "n6JlHK3zql33QpQiiNWk1rC5XQsDk8KB"
default[:nagios][:notifier] = "noop"
default[:nagios][:vhosts] = []
