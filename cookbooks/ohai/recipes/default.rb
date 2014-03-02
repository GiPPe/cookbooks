reload_ohai = false

unless Ohai::Config[:plugin_path].include?(node[:ohai][:plugin_path])
  # we deliberately skip the plugins shipped with ohai. we have them all in our
  # cookbook anyway
  Ohai::Config[:plugin_path] = [node[:ohai][:plugin_path]].flatten.compact
  reload_ohai ||= true
end

node[:ohai][:plugins].each_pair do |source_cookbook, path|
  rd = remote_directory node[:ohai][:plugin_path] do
    cookbook source_cookbook
    source path
    mode '0755'
    recursive true
    purge false
    action :nothing
  end
  rd.run_action(:create)
  reload_ohai ||= rd.updated?
end

resource = ohai 'custom_plugins' do
  action :nothing
end
resource.run_action(:reload) if reload_ohai
