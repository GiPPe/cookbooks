def ovh
  @ovh ||= OVH::REST.new($conf.ovh.app_key, $conf.ovh.app_secret, $conf.ovh.consumer_key)
end

def ovh_servers
  @ovh_servers ||= ovh.get('/dedicated/server').inject({}) do |h, sn|
    s = ovh.get("/dedicated/server/#{sn}")
    h[s['ip']] = s
    h
  end
end

def ovh_reset(ipaddress)
  name = ovh_servers[ipaddress]['name']
  ovh.post("/dedicated/server/#{name}/reboot")
end

def ovh_enable_rescue_wait(ipaddress)
  name = ovh_servers[ipaddress]['name']
  puts "Putting #{name} into rescue mode"
  ovh.put("/dedicated/server/#{name}", 'bootId' => 22)
  ovh_reset(ipaddress)
  wait_for_ssh(name, false)
  ovh.put("/dedicated/server/#{name}", 'bootId' => 1)
end

def ovh_server_name_rdns(ip, fqdn)
  return unless $conf.ovh && $conf.ovh.consumer_key

  server = ovh_servers[ip]

  if server.nil?
    puts "not a ovh machine!"
    return
  end

  puts "Setting reverse DNS for #{ip} to #{fqdn}"
  puts "WARN: this API is not implemented for OVH"
end
