include_recipe "postgresql"

package "dev-db/postgresql-server"
package "dev-ruby/pg"

version = "9.3"
datadir = "/var/lib/postgresql/#{version}/data"

directory datadir do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
end

execute "postgresql-initdb" do
  command "/usr/lib/postgresql-#{version}/bin/initdb --pgdata #{datadir} --locale=en_US.UTF-8"
  user "postgres"
  group "postgres"
  creates File.join(datadir, "PG_VERSION")
end

directory "#{datadir}/pg_log_archive" do
  owner "postgres"
  group "postgres"
  mode "0700"
end

directory "#{datadir}/pg_backup" do
  owner "postgres"
  group "postgres"
  mode "0700"
end

template "#{datadir}/postgresql.conf" do
  source "postgresql.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
  variables datadir: datadir
end

template "#{datadir}/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

template "#{datadir}/pg_ident.conf" do
  source "pg_ident.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

directory "/etc/postgresql-#{version}" do
  action :delete
  recursive true
end

systemd_tmpfiles "postgresql"
systemd_unit "postgresql@.service"

service "postgresql" do
  service_name "postgresql@#{version}.service"
  action [:enable, :start]
  supports [:reload]
end

systemd_timer "postgresql-backup" do
  schedule %w(OnCalendar=daily)
  unit({
    command: [
      "/bin/bash -c 'rm -rf #{datadir}/pg_backup/*'",
      "/usr/bin/pg_basebackup -D #{datadir}/pg_backup -Ft -z -x",
    ],
    user: "postgres",
    group: "postgres",
  })
end

duply_backup "postgresql" do
  source "#{datadir}/pg_backup"
  max_full_backups 30
  max_full_age 1
end
