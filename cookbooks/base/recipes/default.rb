# to make things faster, load data from search index into run_state
node.run_state[:roles] = search(:role).sort_by do |r|
  r.name
end
node.run_state[:users] = search(:users).sort_by do |u|
  u.name
end
node.run_state[:nodes] = search(:node, "ipaddress:[* TO *] AND fqdn:[* TO *]").sort_by do |n|
  n.name
end

# create script path
directory node[:script_path] do
  owner Process.euid
  mode "0755"
end

# load platform recipes
if linux?
  include_recipe "linux"
elsif mac_os_x?
  include_recipe "mac"
else
  raise "cookbook base does not support platform #{node[:platform]}"
end
