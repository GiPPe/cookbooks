nginx_default_use_flags = %w(
  -nginx_modules_http_browser
  -nginx_modules_http_memcached
  -nginx_modules_http_ssi
  -nginx_modules_http_userid
  -syslog
  aio
  nginx_modules_http_gzip_static
  nginx_modules_http_realip
  nginx_modules_http_stub_status
  nginx_modules_http_metrics
)

portage_package_use "www-servers/nginx" do
  use(nginx_default_use_flags + node[:nginx][:use_flags])
end

group "nginx" do
  gid 82
  append true
end

user "nginx" do
  uid 82
  gid 82
  home "/dev/null"
  shell "/sbin/nologin"
  comment "added by portage for nginx"
end

package "www-servers/nginx"

%w(
  /etc/nginx
  /etc/nginx/modules
  /etc/nginx/servers
  /etc/ssl/nginx
  /var/log/nginx
  /var/cache/nginx
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0755"
  end
end

%w(
  /var/tmp/nginx
  /var/tmp/nginx/client
  /var/tmp/nginx/fastcgi
  /var/tmp/nginx/proxy
  /var/tmp/nginx/scgi
  /var/tmp/nginx/uwsgi
).each do |d|
  directory d do
    owner "nginx"
    group "nginx"
    mode "0755"
  end
end

# remove old cruft
%w(
  /etc/nginx/modules/log.conf
  /etc/logrotate.d/nginx
  /etc/ssl/nginx/nginx.key
  /etc/ssl/nginx/nginx.crt
  /etc/ssl/nginx/nginx.csr
).each do |f|
  file f do
    action :delete
  end
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nginx]"
end

include_recipe "nginx::fastcgi"

systemd_tmpfiles "nginx"
systemd_unit "nginx.service"

service "nginx" do
  action [:enable, :start]
end
