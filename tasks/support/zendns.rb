begin
  require 'httparty'
rescue LoadError
  $stderr.puts "HTTParty cannot be loaded. Skipping some rake tasks ..."
end

begin
  require File.expand_path('config/zendns', TOPDIR)
  [ZENDNS_API_URL, ZENDNS_API_TOKEN]
rescue LoadError, Exception
end

class ZenDNS
  include HTTParty if ::Module.const_defined?(:HTTParty)

  if ::Module.const_defined?(:ZENDNS_API_URL)
    base_uri ZENDNS_API_URL
    default_params auth_token: ZENDNS_API_TOKEN, format: :json
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
  return unless ::Module.const_defined?(:ZENDNS_API_URL)

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
