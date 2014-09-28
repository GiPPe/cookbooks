group "spamd" do
  gid 638
end

user "spamd" do
  uid 638
  gid 638
  home "/var/lib/spamassassin"
end

%w(
  mail-filter/dcc
  mail-filter/razor
  mail-filter/spamassassin
).each do |p|
  package p
end

directory "/var/lib/spamassassin" do
  owner "spamd"
  group "spamd"
end

template "/etc/spamassassin/local.cf" do
  source "local.cf"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[spamd]"
end

execute "sa-update" do
  command "/usr/bin/sa-update || :"
  notifies :reload, "service[spamd]"
end

systemd_unit "spamd.service" do
  template true
end

service "spamd" do
  action [:enable, :start]
  supports [:reload]
end

if nagios_client?
  nrpe_command "check_spamd" do
    command "/usr/bin/sa-check_spamd -H localhost -t 10 -w 5 -c 10"
  end

  nagios_service "SPAMD" do
    check_command "check_nrpe!check_spamd"
  end
end
