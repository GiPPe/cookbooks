opts = %w(--journal --rest --quiet --configsvr)

directory node[:mongoc][:dbpath] do
  owner "mongodb"
  group "root"
  mode "0755"
end

systemd_unit "mongoc.service" do
  template true
  notifies :restart, "service[mongoc]"
  variables({
    bind_ip: node[:mongoc][:bind_ip],
    port: node[:mongoc][:port],
    dbpath: node[:mongoc][:dbpath],
    nfiles: node[:mongoc][:nfiles],
    opts: opts,
  })
end

service "mongoc" do
  action [:enable, :start]
end

if nagios_client?
  { # name             command         warn crit check note
    :connect     => %w(connect         2    5    1     15),
    :connections => %w(connections     80   90   1     15),
    :lock        => %w(lock            75   90   60    180),
  }.each do |name, p|
    name = name.to_s
    command_name = "check_mongoc_#{name}"
    service_name = "MONGOC-#{name.upcase.gsub(/_/, '-')}"

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mongodb -H localhost -P #{node[:mongoc][:port]} -A #{p[0]} -W #{p[1]} -C #{p[2]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!#{command_name}"
      check_interval p[3]
      notification_interval p[4]
      servicegroups "mongodb"
    end
  end
end
