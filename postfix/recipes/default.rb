package "mail-mta/postfix"

group "postfix" do
  gid 207
end

group "postdrop" do
  gid 208
end

user "postfix" do
  uid 207
  gid 207
  home "/var/spool/postfix"
end

group "mail" do
  members %w(postfix)
  append true
end

directory "/etc/mail" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/mail/aliases" do
  source "aliases.erb"
  owner "root"
  group "root"
  mode "0644"
end

directory "/etc/postfix" do
  owner "root"
  group "root"
  mode "0755"
end

service "postfix" do
  supports :status => true
  action :enable
end

ipv6_str = node[:ipv6_enabled] ? ", ipv6" : ""

postconf "base" do
  set :myhostname => node[:fqdn],
      :mydomain => node[:domain],
      :mynetworks_style => "host",
      :inet_protocols => "ipv4#{ipv6_str}"
end

execute "newaliases" do
  command "/usr/bin/newaliases"
  not_if do FileUtils.uptodate?("/etc/mail/aliases.db", %w(/etc/mail/aliases)) end
end
