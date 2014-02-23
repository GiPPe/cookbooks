# make the primary IP address overridable
default[:primary_ipaddress] = node[:ipaddress] || "127.0.0.1"
default[:primary_ip6address] = nil

# cluster support
default[:chef_domain] = node[:domain]
default[:cluster][:name] = node[:fqdn]

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

# ec2 support
if node[:ec2] and node[:ec2][:local_ipv4]
  default[:bind_ipaddress] = node[:ec2][:local_ipv4]
else
  default[:bind_ipaddress] = node[:primary_ipaddress]
end

# detect network interfaces
node[:network][:interfaces].each do |name, int|
  next unless int[:addresses]
  if int[:addresses].keys.include?(node[:primary_ipaddress])
    set[:primary_interface] = name
    break
  end
end

# legacy support for local networks
default[:local_ipaddress] = nil

if node[:local_ipaddress]
  node[:network][:interfaces].each do |name, int|
    next unless int[:addresses]
    if int[:addresses].keys.include?(node[:local_ipaddress])
      set[:local_interface] = name
      break
    end
  end
end
