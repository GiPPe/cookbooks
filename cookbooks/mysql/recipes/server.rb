include_recipe "mysql"

if gentoo?
  package "dev-db/innotop"
  package "dev-db/maatkit"
  package "dev-db/mysqltuner"
  package "dev-db/mytop"
  package "dev-db/xtrabackup-bin" if zentoo?
  package "dev-ruby/mysql-ruby"

  # configuration files
  if root?
    directory "/etc/mysql/conf.d" do
      owner "root"
      group "root"
      mode "0755"
    end

    template "/etc/mysql/my.cnf" do
      source "my.cnf"
      owner "root"
      group "root"
      mode "0644"
    end

    template "/etc/logrotate.d/mysql" do
      source "logrotate.conf"
      owner "root"
      group "root"
      mode "0644"
      action :delete if systemd_running?
    end

    directory "/var/log/mysql" do
      owner "mysql"
      group "mysql"
      mode "0755"
    end

    directory "/run/mysqld" do
      owner "mysql"
      group "mysql"
      mode "0755"
    end

    %w(mysql.err mysql.log mysqld.err slow-queries.log).each do |l|
      file "/var/log/mysql/#{l}" do
        owner "mysql"
        group "wheel"
        mode "0640"
        action :delete if systemd_running?
      end
    end

    execute "mysql_pkg_config" do
      command "emerge --config dev-db/mysql"
      creates "/var/lib/mysql/mysql"
    end

    file "/root/.my.cnf" do
      content "[client]\nuser = root\n"
      owner "root"
      group "root"
      mode "0600"
      backup 0
    end

    cookbook_file "/usr/libexec/mysqld-wait-ready" do
      source "mysqld-wait-ready"
      owner "root"
      group "root"
      mode "0755"
    end

    systemd_tmpfiles "mysql"
    systemd_unit "mysql.service"

    service "mysql" do
      action [:enable, :start]
    end

    mysql_user "root" do
      host "%"
      password ""
      force_password true
    end

    mysql_grant "root" do
      database "*"
      user "root"
      user_host "%"
      grant_option true
    end

    mysql_database "test" do
      owner "root"
    end
  end

elsif mac_os_x?
  template "/usr/local/etc/my.cnf" do
    source "my.cnf"
    mode "0644"
  end

  execute "mysql_install_db" do
    command "mysql_install_db --verbose --user=#{node[:current_user]} --basedir=$(brew --prefix mysql) --datadir=/usr/local/var/mysql --tmpdir=/tmp"
    creates "/usr/local/var/mysql/mysql"
  end

  file "#{node[:homedir]}/.my.cnf" do
    content "[client]\nuser = root\n"
    mode "0600"
    backup 0
  end

end

# nagios service checks
if nagios_client?

  # simple helper class for custom nagios checks
  cookbook_file "/usr/lib/ruby/site_ruby/nagios/plugin/mysql.rb" do
    source "nagios-mysql.rb"
    owner "root"
    group "root"
    mode "0644"
  end

  file "/var/nagios/home/.my.cnf" do
    content "[client]\nuser = root\n"
    owner "nagios"
    group "nagios"
    mode "0600"
    backup 0
  end

  mysql_user "nagios" do
    action :delete
  end

  # instead use patched version with my.cnf support
  nagios_plugin "check_mysql_health"

  node[:mysql][:server][:nagios].each do |name, params|
    command_name = "check_mysql_#{name}"
    service_name = "MYSQL-#{name.upcase}"

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mysql_health --mode #{params[:command]} --warning #{params[:warning]} --critical #{params[:critical]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!check_mysql_#{name}"
      check_interval params[:check_interval]
      notification_interval params[:notification_interval]
      servicegroups "mysql"
      enabled params[:enabled]
    end
  end

  nagios_service_dependency "MYSQL-SLAVELAG" do
    depends %w(MYSQL-SLAVEIO MYSQL-SLAVESQL)
  end
end
