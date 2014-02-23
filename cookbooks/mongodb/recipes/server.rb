include_recipe "mongodb"

if gentoo?
  if root?
    opts = %w(--journal --rest --quiet)

    opts << "--oplogSize #{node[:mongodb][:oplog][:size]}" if node[:mongodb][:oplog][:size]
    opts << "--slowms #{node[:mongodb][:slowms]}"

    opts << "--shardsvr" if node[:mongodb][:shardsvr]
    opts << "--replSet #{node[:mongodb][:replication][:set]}" if node[:mongodb][:replication][:set]

    directory node[:mongodb][:dbpath] do
      owner "mongodb"
      group "root"
      mode "0755"
    end

    systemd_unit "mongodb.service" do
      template true
      variables({
        bind_ip: node[:mongodb][:bind_ip],
        port: node[:mongodb][:port],
        dbpath: node[:mongodb][:dbpath],
        nfiles: node[:mongodb][:nfiles],
        opts: opts,
      })
    end

    service "mongodb" do
      action [:enable, :start]
    end
  end
end

if nagios_client?
  { # name             command         warn crit check note
    :connect     => %w(connect         2    5    1     15),
    :connections => %w(connections     80   90   1     15),
    :lock        => %w(lock            75   90   60    180),
    :repl_lag    => %w(replication_lag 60   900  60    180),
    :repl_state  => %w(replset_state   0    0    1     15),
  }.each do |name, p|
    name = name.to_s
    command_name = "check_mongodb_#{name}"
    service_name = "MONGODB-#{name.upcase.gsub(/_/, '-')}"

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mongodb -H localhost -P #{node[:mongodb][:port]} -A #{p[0]} -W #{p[1]} -C #{p[2]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!#{command_name}"
      check_interval p[3]
      notification_interval p[4]
      servicegroups "mongodb"
    end
  end

  unless opts.any? { |o| o.match(/--replSet/) }
    node.default[:nagios][:services]["MONGODB-REPL-STATE"][:enabled] = false
    node.default[:nagios][:services]["MONGODB-REPL-LAG"][:enabled] = false
  end
end
