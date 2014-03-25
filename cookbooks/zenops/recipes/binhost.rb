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

file "/usr/sbin/pkgsync" do
  action :delete
end

systemd_timer "pkgsync" do
  action :delete
end
