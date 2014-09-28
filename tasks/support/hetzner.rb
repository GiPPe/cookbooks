def hetzner
  @hetzner ||= Hetzner::API.new($conf.hetzner.username, $conf.hetzner.password)
end

def hetzner_server_name_rdns(ip, fqdn)
  return unless $conf.hetzner && $conf.hetzner.username

  server = hetzner.server?(ip)

  if server['error']
    puts "not a hetzner machine!"
    return
  end

  puts "Setting reverse DNS for #{ip} to #{fqdn}"
  hetzner.server!(ip, server_name: fqdn)
  hetzner.rdns!(ip, fqdn)
end

def hetzner_enable_rescue_wait(ip)
  hetzner.disable_rescue!(ip)
  res = hetzner.enable_rescue!(ip, 'linux', '64')
  password = res.parsed_response["rescue"]["password"]
  puts "rescue password is #{password.inspect}"
  hetzner.reset!(ip, :hw)
  wait_for_ssh(ip, false)
  password
end
