include_recipe "nepal::base"

mysql_user_password = get_password("mysql/nepal_nss_user")
mysql_root_password = get_password("mysql/nepal_nss_root")

mysql_database_user "nepal_nss_user" do
  connection node[:mysql][:connection]
  host "%"
  password mysql_user_password
  database_name "nepal"
  privileges %w(SELECT)
  action :grant
end

mysql_database_user "nepal_nss_root" do
  connection node[:mysql][:connection]
  host "%"
  password mysql_root_password
  database_name "nepal"
  privileges %w(SELECT)
  action :grant
end

package "sys-auth/libnss-mysql"

template "/etc/libnss-mysql.cfg" do
  source "nss/libnss-mysql.cfg"
  owner "root"
  group "root"
  mode "0644"
  variables :database_password => mysql_user_password
end

template "/etc/libnss-mysql-root.cfg" do
  source "nss/libnss-mysql-root.cfg"
  owner "root"
  group "root"
  mode "0644"
  variables :database_password => mysql_root_password
end

node.default[:nss][:modules][:passwd] = %w(files mysql)
node.default[:nss][:modules][:shadow] = %w(files mysql)
node.default[:nss][:modules][:group] = %w(files mysql)
