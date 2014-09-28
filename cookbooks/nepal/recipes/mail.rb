include_recipe "nepal::base"

portage_package_use "mail-mta/postfix|mysql" do
  package "mail-mta/postfix"
  use %w(mysql)
end

include_recipe "postfix::local"

mysql_dom_password = get_password("mysql/nepal_mail_dom")
mysql_user_password = get_password("mysql/nepal_mail_user")
mysql_alias_password = get_password("mysql/nepal_mail_alias")

mysql_database_user "nepal_mail_dom" do
  connection node[:mysql][:connection]
  host "%"
  password mysql_dom_password
  database_name "nepal"
  privileges %w(SELECT)
  action :grant
end

mysql_database_user "nepal_mail_user" do
  connection node[:mysql][:connection]
  host "%"
  password mysql_user_password
  database_name "nepal"
  privileges %w(SELECT)
  action :grant
end

mysql_database_user "nepal_mail_alias" do
  connection node[:mysql][:connection]
  host "%"
  password mysql_alias_password
  database_name "nepal"
  privileges %w(SELECT)
  action :grant
end

%w(
  virtual-alias-maps
  virtual-email2email-maps
  virtual-gid-maps
  virtual-mailbox-domains
  virtual-mailbox-maps
  virtual-uid-maps
).each do |c|
  template "/etc/postfix/mysql-#{c}.cf" do
    source "mail/mysql-#{c}.cf"
    owner "root"
    group "postfix"
    mode "0640"
    notifies :reload, "service[postfix]"
    variables({
      dom_password: mysql_dom_password,
      user_password: mysql_user_password,
      alias_password: mysql_alias_password,
    })
  end
end

postconf "nepal virtual maps" do
  set({
    virtual_mailbox_domains: "proxy:mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf",
    virtual_mailbox_maps: "proxy:mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf",
    virtual_alias_maps: "proxy:mysql:/etc/postfix/mysql-virtual-alias-maps.cf,proxy:mysql:/etc/postfix/mysql-virtual-email2email-maps.cf",
    virtual_uid_maps: "proxy:mysql:/etc/postfix/mysql-virtual-uid-maps.cf",
    virtual_gid_maps: "proxy:mysql:/etc/postfix/mysql-virtual-gid-maps.cf",
    virtual_transport: "lmtp:unix:private/dovecot-lmtp",
    proxy_read_maps: "$local_recipient_maps $mydestination $virtual_alias_maps $virtual_alias_domains $virtual_mailbox_maps $virtual_mailbox_domains $virtual_uid_maps $virtual_gid_maps $relay_recipient_maps $relay_domains $canonical_maps $sender_canonical_maps $recipient_canonical_maps $relocated_maps $transport_maps $mynetworks $sender_bcc_maps $recipient_bcc_maps $smtp_generic_maps $lmtp_generic_maps",
  })
end

portage_package_use "net-mail/dovecot|mysql" do
  package "net-mail/dovecot"
  use %w(mysql suid)
end

node.default[:dovecot][:auth][:modules] = %w(nepal)
node.default[:dovecot][:sieve][:path] = "/srv/system/etc/sieve/%d/%n.sieve"

include_recipe "dovecot"

directory "/srv/system/etc/sieve" do
  owner "nepal"
  group "nepal"
  mode "0755"
end

template "/etc/dovecot/nepal-sql.conf.ext" do
  source "mail/nepal-sql.conf.ext"
  owner "root"
  group "root"
  mode "0600"
  notifies :restart, "service[dovecot]"
  variables user_password: mysql_user_password
end

template "/etc/dovecot/conf.d/auth-nepal.conf.ext" do
  source "mail/auth-nepal.conf.ext"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[dovecot]"
end

shorewall_rule "mail" do
  destport "25,465,110,143,993,995"
end

shorewall6_rule "mail" do
  destport "25,465,110,143,993,995"
end
