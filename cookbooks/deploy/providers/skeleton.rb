include AccountHelpers

use_inline_resources

action :create do
  nr = new_resource
  user = nr.name
  groups = nr.groups
  key_source = nr.key_source
  akf = nr.authorized_keys_for

  if akf != false
    akf = node[:deploy][:deployers] if akf.nil? or akf.empty?
  end

  if nr.homedir == nil
    homedir = get_user(user)[:dir] || "/var/app/#{user}"
  else
    homedir = nr.homedir
  end

  group user do
    gid nr.gid if nr.gid
  end

  account_skeleton user do
    comment user
    home homedir
    home_mode "0755"
    uid nr.uid if nr.uid
    gid user
    groups groups
    authorized_keys_for akf if akf
    key_source key_source if key_source
  end

  %w(
    bin
    releases
    shared
  ).each do |d|
    directory "#{homedir}/#{d}" do
      owner user
      group user
      mode "0755"
    end
  end

  shared = %w(cache config log pids system) + nr.shared

  shared.uniq.each do |d|
    directory "#{homedir}/shared/#{d}" do
      owner user
      group user
      mode "0755"
    end
  end

  splunk_input "monitor://#{homedir}/shared/log/*.log"

  file "/etc/logrotate.d/deploy-#{user}" do
    content <<-EOS
#{homedir}/shared/log/*.log {
 missingok
 rotate 21
 copytruncate
}
EOS
    owner "root"
    group "root"
    mode "0644"
  end

end
