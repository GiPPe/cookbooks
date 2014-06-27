if gentoo?
  package "dev-db/redis"
elsif mac_os_x?
  package "redis"
end

if root?
  template "/etc/redis.conf" do
    source "redis.conf"
    owner "root"
    group "root"
    mode "0644"
  end

  systemd_unit "redis.service"

  service "redis" do
    action [:enable, :start]
  end

  duply_backup "redis" do
    source "/var/lib/redis"
  end
end
