remote_directory node[:ohai][:plugin_path] do
  source "plugins"
  mode "0755"
  recursive true
  purge false
  action :nothing
end.run_action(:create)

Ohai::Config[:plugin_path] = [node[:ohai][:plugin_path]]

ohai = ::Ohai::System.new
ohai.all_plugins

recipes, roles = node.automatic_attrs[:recipes], node.automatic_attrs[:roles]
node.automatic_attrs.clear
node.automatic_attrs.merge!(ohai.data)
node.automatic_attrs[:recipes] = recipes
node.automatic_attrs[:roles] = roles
