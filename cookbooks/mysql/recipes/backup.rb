%w(
  mysql_full_backup
  mysql_full_clean
  mysql_binlog_backup
  mysql_binlog_clean
).each do |f|
  template "/usr/local/sbin/#{f}" do
    source "#{f}.sh"
    owner "root"
    group "root"
    mode "0750"
  end
end

if node[:mysql][:backup][:mode] == "copy"
  directory node[:mysql][:backup][:copy][:dir] do
    owner "root"
    group "root"
    mode "0700"
    recursive true
  end
end

if mysql_nodes.length > 1
  if node[:mysql][:server][:active_master]
    action = :delete
  else
    action = :create
  end
else
  action = :create
end

cron "mysql_full_backup" do
  action action
  minute "0"
  hour node[:mysql][:backup][:full_backup][1]
  weekday node[:mysql][:backup][:full_backup][0]
  command "/usr/local/sbin/mysql_full_backup"
end

cron "mysql_full_clean" do
  action action
  minute "0"
  hour node[:mysql][:backup][:full_clean][1]
  weekday node[:mysql][:backup][:full_clean][0]
  command "/usr/local/sbin/mysql_full_clean"
end

cron "mysql_binlog_backup" do
  action action
  minute "3,33"
  command "/usr/local/sbin/mysql_binlog_backup"
end

cron "mysql_binlog_clean" do
  action action
  minute "0"
  hour node[:mysql][:backup][:binlog_clean][1]
  weekday node[:mysql][:backup][:binlog_clean][0]
  command "/usr/local/sbin/mysql_binlog_clean"
end
