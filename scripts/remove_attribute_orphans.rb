nodes.all do |node|
  [:default, :normal, :override].each do |level|
    a = node.send((level.to_s + '_attrs').to_sym)

    # munin
    a[:tags].delete("munin-node") rescue nil
    a[:nagios][:services].delete("MUNIN-NODE") rescue nil
    a.delete(:munin) rescue nil

    # splunk
    a[:splunk][:inputs].delete("monitor:///var/log/nginx/access_log") rescue nil
    a[:splunk][:inputs].delete("monitor:///var/log/chef/client.log") rescue nil

    # ipv6
    a.delete(:ipv6_enabled) rescue nil

    # zentoo next
    a[:portage].delete("SYNC") rescue nil

    # cleanup
    a.delete(:tags) if a[:tags].empty?
  end

  # legacy normal attributes
  %w(
    backup
    chef_domain
    classification
    cron
    lftp
    nagios
    packages
    php
    portage
    primary_interface
    primary_ipaddress
    shorewall
    shorewall6
    splunk
    ssh
    sudo
  ).each do |attr|
    node.normal_attrs.delete(attr) rescue nil
  end

  node.save
end
