begin
  require 'httparty'
rescue LoadError
end

class ZenDNS
  include HTTParty if ::Module.const_defined?(:HTTParty)

  if $conf.zendns && $conf.zendns.token
    base_uri $conf.zendns.url
    default_params auth_token: $conf.zendns.token, format: :json
  end

  def self.domains
    JSON.parse(get("/domains").body)
  end

  def self.records(domain_id)
    JSON.parse(get("/domains/#{domain_id}/records").body)
  end

  def self.create_record(domain_id, record)
    response = post("/domains/#{domain_id}/records", body: {
      record: record
    }).response
    raise "failed to create record" unless response.is_a?(Net::HTTPOK)
  end
end

def zendns_add_record(fqdn, ip)
  return unless $conf.zendns && $conf.zendns.token

  domain = ZenDNS.domains.select do |d|
    fqdn =~ /\.#{d['name']}\Z/
  end.sort_by do |d|
    d['name'].length
  end.last

  hostname = fqdn.sub(/\.#{domain['name']}\Z/, '')

  records = ZenDNS.records(domain['_id']).select do |r|
    r['name'] == hostname
  end

  if records.empty?
    puts "Creating DNS record in ZenDNS (#{fqdn} -> #{ip})"
    ZenDNS.create_record(domain['_id'], {
      name: hostname,
      type: 'A',
      priority: '0',
      content: ip,
    })
  else
    good = records.any? { |r| r['content'] == ip }
    raise "ZenDNS records do not match for #{fqdn}/#{ip}" unless good
  end
end
