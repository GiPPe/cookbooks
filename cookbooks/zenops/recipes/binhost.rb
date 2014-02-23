include_recipe "zenops::mirror-zentoo"

directory "/var/cache/mirror/zentoo/amd64" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/var/cache/mirror/zentoo/amd64/packages" do
  owner "root"
  group "root"
  mode "0755"
end

template "/usr/sbin/pkgsync" do
  source "pkgsync.sh"
  owner "root"
  group "root"
  mode "0755"
  variables :clients => pkgsync_client_nodes.map { |n| n[:ipaddress] }
end

systemd_unit "pkgsync.service"

systemd_timer "pkgsync" do
  schedule "OnCalendar=*:25"
end
