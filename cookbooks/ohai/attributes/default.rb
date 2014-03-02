if root?
  default[:ohai][:plugin_path] = "/var/lib/ohai/plugins"
else
  default[:ohai][:plugin_path] = "#{get_user(node[:current_user])[:dir]}/.ohai/plugins"
end

default[:ohai][:plugins][:ohai] = "plugins"
