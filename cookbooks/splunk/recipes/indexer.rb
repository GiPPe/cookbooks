tag("splunk-indexer")

package "net-analyzer/splunk"

include_recipe "splunk::default"

splunk_users = Proc.new do |u|
  (u[:tags]) and
  (u[:tags].include?("hostmaster") or u[:tags].include?("splunk")) and
  (u[:password1] and u[:password1] != '!')
end

passwd_content = node.run_state[:users].select(&splunk_users).map do |user|
  ":#{user[:id]}:#{user[:password1]}::#{user[:comment]}:admin:#{user[:email]}:"
end.join("\n")

file "/opt/splunk/etc/passwd" do
  content passwd_content
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
end


%w(
  eventtypes
  indexes
  props
  tags
  transforms
).each do |c|
  template "/opt/splunk/etc/system/local/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
  end
end

# this is in default rather than local, since splunk seems to have some
# problems with overriding the saved searches in local files
template "/opt/splunk/etc/apps/search/default/savedsearches.conf" do
  source "savedsearches.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
end

## syslog -> splunk
include_recipe "syslog::server"

syslog_config "90-splunk" do
  template "syslog.conf"
end

remote_directory "/opt/splunk/etc/apps/syslog_priority_lookup" do
  source "apps/syslog_priority_lookup"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end

## nginx ssl proxy
include_recipe "nginx"

htpasswd_from_databag "/etc/nginx/servers/splunk.passwd" do
  query splunk_users
  group "nginx"
  password_field :password1
end

nginx_server "splunk" do
  template "nginx.conf"
end
