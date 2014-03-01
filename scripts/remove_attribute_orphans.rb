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
  end

  a = node.normal_attrs
  a.keys.each do |attr|
    a.delete(attr) rescue nil
  end

  node.save
end
