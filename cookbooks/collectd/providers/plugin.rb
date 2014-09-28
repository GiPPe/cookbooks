def whyrun_supported?
  true
end

action :create do
  nr = new_resource

  use_flags = [nr.name] + nr.use
  use_flags.map! do |flag|
    "collectd_plugins_#{flag}"
  end

  portage_package_use "app-admin/collectd|#{nr.name}" do
    package "app-admin/collectd"
    use use_flags
  end

  template "/etc/collectd.d/#{nr.name}.conf" do
    source nr.source || "plugin.conf"
    cookbook nr.source ? nr.cookbook : "collectd"
    owner "root"
    group "root"
    mode "0640"
    notifies :restart, "service[collectd]"
    variables({
      name: nr.name,
    })
  end
end

action :delete do
  nr = new_resource

  file "/etc/collectd.d/#{nr.name}.conf" do
    action :delete
    notifies :restart, "service[collectd]"
  end
end
