nginx_default_use_flags = %w(
  -nginx_modules_http_browser
  -nginx_modules_http_memcached
  -nginx_modules_http_ssi
  -nginx_modules_http_userid
  -syslog
  aio
  nginx_modules_http_realip
  nginx_modules_http_stub_status
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

systemd_tmpfiles "nginx"

systemd_unit "nginx.service"

service "nginx" do
  action [:enable, :start]
end

ssl_certificate "/etc/ssl/nginx/nginx" do
  cn node[:fqdn]
  owner "nginx"
  group "nginx"
  notifies :restart, "service[nginx]"
end

%w(csr pem).each do |f|
  file "/etc/ssl/nginx/nginx.#{f}" do
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

nginx_module "log" do
  template "log.conf"
end

cookbook_file "/etc/logrotate.d/nginx" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

nginx_module "fastcgi" do
  template "fastcgi.conf"
end

link "/etc/nginx/fastcgi.conf" do
  to "/etc/nginx/modules/fastcgi.conf"
end

link "/etc/nginx/fastcgi_params" do
  to "/etc/nginx/modules/fastcgi.conf"
end

nginx_server "status" do
  template "status.conf"
end

if tagged?("nagios-client")
  nrpe_command "check_nginx" do
    command "/usr/lib/nagios/plugins/check_systemd nginx.service /run/nginx.pid /usr/sbin/nginx"
  end

  nagios_service "NGINX" do
    check_command "check_nrpe!check_nginx"
  end
end

if tagged?("ganymed-client")
  ganymed_collector "nginx" do
    source "nginx.rb"
  end
end
