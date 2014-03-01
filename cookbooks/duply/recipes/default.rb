if gentoo?
  package "net-ftp/ncftp"
  package "app-backup/duply"
elsif debian_based?
  package "ncftp"
  package "duply"
end

%w(
  /etc/duply
  /var/tmp/backup
  /var/cache/backup
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0700"
  end
end

if nagios_client?
  nagios_plugin "check_duplybackup"
end

node.default[:lftp][:bookmarks][:backup] = node[:backup][:target_base_url].sub(/^ssh:/, "sftp:")

node[:backup][:configs].each do |name, params|
  directory "/etc/duply/#{name}" do
    owner "root"
    group "root"
    mode "0700"
  end

  directory "/var/log/duply/#{name}" do
    owner "root"
    group "root"
    mode "0755"
    recursive true
  end

  template "/etc/duply/#{name}/conf" do
    source "duply.conf"
    owner "root"
    group "root"
    mode "0600"
    variables(params)
  end

  cron_daily "duply-bkp-#{name}" do
    command "/usr/bin/duply #{name} bkp > /var/log/duply/#{name}/$(date +%Y-%m-%d).log"
  end

  cron_weekly "duply-purge-#{name}" do
    command "/usr/bin/duply #{name} purge-full --force &> /dev/null"
  end

  splunk_input "monitor:///var/log/duply/#{name}/*.log"

  if nagios_client?
    nrpe_command "check_duplybackup_#{name}" do
      command "/usr/lib/nagios/plugins/check_duplybackup #{name}"
    end

    nagios_service "DUPLYBACKUP-#{name.upcase}" do
      check_command "check_nrpe!check_duplybackup_#{name}"
      check_interval 1440
      notification_interval 180
      env [:testing, :development]
    end
  end
end
