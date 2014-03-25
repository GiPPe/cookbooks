# cluster support
default[:chef_domain] = node[:domain]

if match = node[:fqdn].sub(node[:chef_domain], '').match(/^(.+?)\.(.+?)\.$/)
  default[:cluster][:name] = match[2]
else
  default[:cluster][:name] = node[:fqdn]
end

if match = node[:hostname].match(/(.+?)(\d+)$/)
  default[:cluster][:host][:group] = match[1]
  default[:cluster][:host][:id] = match[2].to_i
else
  default[:cluster][:host][:group] = node[:hostname]
  default[:cluster][:host][:id] = 1
end

# contacts
default[:contacts][:hostmaster] = "hostmaster@#{node[:chef_domain]}"

# support non-root runs
if root?
  default[:homedir] = "/root"
  default[:current_email] = "root@localhost"
  default[:current_name] = "Hostmaster of the day"
  default[:script_path] = "/usr/local/bin"
else
  default[:homedir] = get_user(node[:current_user])[:dir]
  default[:current_email] = "#{node[:current_user]}@#{node[:fqdn]}"
  default[:current_name] = get_user(node[:current_user])[:gecos]
  default[:script_path] = "#{node[:homedir]}/bin"
end
