include AccountHelpers

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = nr.path || nr.homedir || user[:dir]
  port = nr.port.to_i

  service "nginx" do
    action :nothing
  end

  template "/etc/nginx/servers/unicorn-#{nr.name}.conf" do
    source "unicorn.conf"
    cookbook "nginx"
    owner "root"
    group "root"
    mode "0644"
    notifies :reload, "service[nginx]"
    variables params: {
      user: user[:name],
      path: path,
      port: port,
    }
  end
end

action :delete do
  nr = new_resource # rebind

  service "nginx" do
    action :nothing
  end

  file "/etc/nginx/servers/unicorn-#{nr.name}.conf" do
    action :delete
    notifies :reload, "service[nginx]"
  end
end
