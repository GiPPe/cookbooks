if gentoo?
  template "/etc/env.d/99splunk" do
    source "99splunk"
    owner "root"
    group "root"
    mode "0644"
    notifies :run, 'execute[env-update]'
  end
end

if splunk6_master_node.nil? or splunk6_master_node[:fqdn] == node[:fqdn]
  pass4symmkey = get_password("splunk/pass4symmkey")
  node.default[:splunk][:pass4symmkey] = pass4symmkey
else
  pass4symmkey = splunk6_master_node[:splunk][:pass4symmkey]
end

# misuse the pass4symmkey as admin password
admin_password = pass4symmkey.crypt("$1$159c1407ab01798d$")

splunk_users = node.run_state[:users].select do |u|
  (u[:tags]) and
  (u[:tags].include?("hostmaster") or u[:tags].include?("splunk")) and
  (u[:password1] and u[:password1] != '!')
end.sort_by do |u|
  u[:id]
end

template "/opt/splunk/etc/passwd" do
  source "passwd"
  owner "root"
  group "root"
  mode "0644"
  variables({
    splunk_users: splunk_users,
    admin_password: admin_password,
  })
end

template "/root/.splunkrc" do
  source "splunkrc"
  owner "root"
  group "root"
  mode "0400"
  variables(pass4symmkey: pass4symmkey)
end

directory "/opt/splunk/etc/system/local" do
  owner "root"
  group "root"
  mode "0755"
end

%w(
  inputs
  outputs
  prefs
  times
  web
).each do |c|
  template "/opt/splunk/etc/system/local/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0644"
    # only restart forwarders automatically
    notifies :restart, "service[splunk]" if splunk6_forwarder?
    variables(pass4symmkey: pass4symmkey)
  end
end

# local/server.conf is overwritten by splunk on every restart and then
# overwritten by every chef-client run, and again and again.
# so we just overwrite the default/server.conf *sigh
template "/opt/splunk/etc/system/default/server.conf" do
  source "server.conf"
  owner "root"
  group "root"
  mode "0644"
  # only restart forwarders automatically
  notifies :restart, "service[splunk]" if splunk6_forwarder?
  variables(pass4symmkey: pass4symmkey)
end

execute "splunk-enable-boot" do
  command "/opt/splunk/bin/splunk enable boot-start --no-prompt --answer-yes --accept-license"
  creates "/etc/init.d/splunk"
  only_if { debian_based? }
end

systemd_unit "splunk.service" do
  template true
end

service "splunk" do
  action [:enable, :start]
end
