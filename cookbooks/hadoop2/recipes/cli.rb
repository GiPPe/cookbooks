include_recipe "hadoop2"

template "/etc/env.d/98hadoop2" do
  source "98hadoop2"
  owner "root"
  group "root"
  mode 0644
  notifies :run, 'execute[env-update]'
end
