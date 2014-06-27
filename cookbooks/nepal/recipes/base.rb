include_recipe "mysql::server"

# we need this in the base recipe so we can create directories for user apache
node.default[:apache][:default_vhost] = false
node.default[:apache][:mpm] = "prefork"
include_recipe "apache"

# system database
mysql_password = get_password("mysql/nepal")

mysql_user "nepal" do
  password mysql_password
  force_password true
end

mysql_grant "nepal" do
  database "*"
  user "nepal"
  grant_option true
end

mysql_database "nepal" do
  owner "nepal"
end

#package "www-apps/nepal"

# system directories
directory "/srv" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/srv/system" do
  owner "nepal"
  group "nepal"
  mode "0755"
end

%w(
  etc
  bin
).each do |d|
  directory "/srv/system/#{d}" do
    owner "nepal"
    group "nepal"
    mode "0755"
  end
end

%w(
  htdocs
  htdocs/default
  htdocs/inactive
  logs
  panel
  tmp
).each do |d|
  directory "/srv/system/#{d}" do
    owner "nepal"
    group "apache"
    mode "0750"
  end
end

# index.html for default and inactive accounts
%w(default inactive).each do |p|
  cookbook_file "/srv/system/htdocs/#{p}/index.html" do
    source "base/index.#{p}.html"
    owner "nepal"
    group "apache"
    mode "0640"
  end
end

# ui configuration
file "/srv/system/panel/__init__.py" do
  content ""
  owner "nepal"
  group "apache"
  mode "0640"
end

secret_key = get_password("nepal/secret_key", 50)

template "/srv/system/panel/settings.py" do
  source "base/settings.py"
  owner "nepal"
  group "apache"
  mode "0640"
  notifies :restart, "service[nepald]"
  notifies :reload, "service[apache2]"
  variables({
    database_password: mysql_password,
    secret_key: secret_key,
  })
end

execute "nepal-syncdb" do
  command "/usr/sbin/nepal-admin syncdb --noinput"
end

execute "nepal-migratedb" do
  command "/usr/sbin/nepal-admin migrate"
end

systemd_unit "nepald.service"

service "nepald" do
  action [:enable, :start]
end

# phpMyAdmin
git "/srv/system/htdocs/mysqladmin" do
  repository "https://github.com/phpmyadmin/phpmyadmin"
  revision "RELEASE_3_4_7_1"
  user "nepal"
  group "nepal"
end

template "/srv/system/htdocs/mysqladmin/config.inc.php" do
  source "base/phpmyadmin.config.php"
  owner "root"
  group "root"
  mode "0644"
  variables secret_key: secret_key
end

# roundcube
package "dev-vcs/subversion"

git "/srv/system/htdocs/webmail" do
  repository "https://github.com/roundcube/roundcubemail"
  revision "v0.7.2"
  user "nepal"
  group "nepal"
end

mysql_password = get_password("mysql/roundcube")

mysql_user "roundcube" do
  password mysql_password
  force_password true
end

mysql_database "roundcube" do
  owner "roundcube"
end

execute "roundcube_init" do
  command "mysql roundcube < /srv/system/htdocs/webmail/SQL/mysql.initial.sql"
  creates "/var/lib/mysql/roundcube/identities.frm"
end

template "/srv/system/htdocs/webmail/config/main.inc.php" do
  source "base/roundcube.main.inc.php"
  owner "root"
  group "root"
  mode "0644"
  variables secret_key: secret_key
end

template "/srv/system/htdocs/webmail/config/db.inc.php" do
  source "base/roundcube.db.inc.php"
  owner "root"
  group "root"
  mode "0644"
  variables mysql_password: mysql_password
end

# logrotate customer logfiles
template "/etc/logrotate.d/nepal-customers" do
  source "base/logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

duply_backup "nepal-srv" do
  source "/srv"
end
