service "systemd-sysctl.service" do
  action [:enable, :start]
  only_if { systemd_running? }
end

execute "sysctl-reload" do
  command "/sbin/sysctl -p /etc/sysctl.conf"
  command "/usr/lib/systemd/systemd-sysctl" if systemd_running?
  action :nothing
end

link "/etc/sysctl.conf" do
  to "/etc/sysctl.d/base.conf"
end

directory "/etc/sysctl.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/sysctl.d/base.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf"
  notifies :run, "execute[sysctl-reload]"
end

template "/etc/security/limits.conf" do
  source "limits.conf"
  owner "root"
  group "root"
  mode "0644"
end
