unless node[:skip][:shorewall]
  # detect bridge
  if node[:network][:default_interface_bridged]
    shorewall_interface "br" do
      interface "#{node[:network][:default_interface]}:#{node[:network][:default_interface_bridged]}"
    end

    shorewall_zone "br:net" do
      type "bport"
    end

    shorewall_policy "br" do
      source "br"
      dest "all"
      policy "ACCEPT"
    end
  end

  include_recipe "shorewall::ipv4"
  include_recipe "shorewall::ipv6"

  if nagios_client?
    nagios_plugin "check_conntrack"

    nrpe_command "check_conntrack" do
      command "/usr/lib/nagios/plugins/check_conntrack 75 90"
    end

    nagios_service "CONNTRACK" do
      check_command "check_nrpe!check_conntrack"
      notification_interval 15
      servicegroups "system"
      env [:testing, :development]
    end
  end
end
