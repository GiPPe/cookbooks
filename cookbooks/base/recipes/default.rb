# to make things faster, load data from search index into run_state
if Chef::Config[:solo]
  node.run_state[:roles] = []
  node.run_state[:users] = []
  node.run_state[:nodes] = [node]
else
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
  node.run_state[:nodes] = search(:node, "ipaddress:[* TO *] AND fqdn:[* TO *]").sort_by do |n|
    n[:fqdn]
  end
  if node.run_state[:nodes].none? { |n| n[:fqdn] == node[:fqdn] }
    node.run_state[:nodes] << node
  end
end

# filter nodes that belong to the same cluster as the current node
node.run_state[:cluster_nodes] = node.run_state[:nodes].select do |n|
  n.cluster_name == node.cluster_name rescue false
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
