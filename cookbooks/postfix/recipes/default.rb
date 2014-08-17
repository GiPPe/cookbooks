if gentoo?
  portage_package_use "mail-mta/postfix" do
    use node[:postfix][:use_flags].sort.uniq
  end

  package "mail-mta/postfix"

  user "postmaster" do
    gid "postmaster"
    comment "added by portage for mailbase"
    home "/var/spool/mail"
    shell "/sbin/nologin"
  end

  user "postfix" do
    gid "postfix"
    comment "added by portage for postfix"
    home "/var/spool/postfix"
    shell "/sbin/nologin"
  end

elsif debian_based?
  package "postfix"

  user "postfix" do
    gid "postfix"
    home "/var/spool/postfix"
    shell "/bin/false"
  end

end

group "mail" do
  members %w(postfix)
  append true
end

directory "/var/mail" do
  action :delete
  recursive true
  not_if { File.symlink?("/var/mail") }
end

link "/var/spool/mail" do
  action :delete
  only_if { File.symlink?("/var/spool/mail") }
end

directory "/var/spool/mail" do
  owner "root"
  group "mail"
  mode "03775"
end

link "/var/mail" do
  to "/var/spool/mail"
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

ipv6_str = node[:ip6address] ? ", ipv6" : ""

postconf "base" do
  set({
    myhostname: node[:fqdn],
    mydomain: node[:domain],
    mynetworks_style: "host",
    inet_protocols: "ipv4#{ipv6_str}",
    message_size_limit: node[:postfix][:message_size_limit].to_i * 1024 * 1024,
  })
end

postmaster "smtp" do
  stype "inet"
  priv "n"
  command "smtpd"
end

postmaster "smtps" do
  stype "inet"
  priv "n"
  command "smtpd"
  args "-o smtpd_tls_wrappermode=yes -o smtpd_sasl_auth_enable=yes -o smtpd_client_restrictions=permit_sasl_authenticated,reject"
end

# global recipient blacklist
blacklist = (node[:postfix][:recipient] || {}).map { |k, v| "#{k} #{v}" }.join("\n")

file "/etc/postfix/recipient" do
  content blacklist
  owner "root"
  group "root"
  mode "0644"
end

execute "postmap-recipient" do
  command "postmap /etc/postfix/recipient"
  only_if { FileUtils.uptodate?('/etc/postfix/recipient', ['/etc/postfix/recipient.db']) }
end

systemd_unit "postfix.service"

service "postfix" do
  action [:enable, :start]
end

execute "newaliases" do
  command "/usr/bin/newaliases"
  not_if do FileUtils.uptodate?("/etc/mail/aliases.db", %w(/etc/mail/aliases)) end
end

if nagios_client?
  nrpe_command "check_smtp" do
    command "/usr/lib/nagios/plugins/check_smtp -H localhost -t 3"
  end

  nagios_service "SMTP" do
    check_command "check_nrpe!check_smtp"
    env [:testing, :development]
  end
end
