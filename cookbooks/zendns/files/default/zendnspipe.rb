#!/usr/bin/env ruby

require 'mongo'
$con = Mongo::ReplSetConnection.new(['localhost:27017'])
$db = $con.db("zendns_production")

def failed(reason)
  puts "FAIL\t#{reason}"
  nil
end

def debug(msg)
  STDERR.puts(msg)
end

def get_domain(qname, domain_id)
  if domain_id and domain_id > 0
    debug("trying to find domain with id=#{domain_id}")
    return $db['domains'].find_one(:_id => domain_id)
  end

  sdom = qname.dup

  while sdom.index('.')
    debug("trying to find domain with name=#{sdom}")
    result = $db['domains'].find_one(:name => sdom)
    return result if result
    sdom.sub!(/^[^.]+\./, '')
  end

  return nil
end

def print_domain(qname, domain_id)
  domain = get_domain(qname, domain_id)
  return unless domain
  puts "DATA\t#{domain['name']}\tIN\tSOA\t7200\t#{domain['_id']}\t#{domain['nameserver']}. #{domain['hostmaster']}. #{domain['serial']} #{domain['ttl']} 3600 604800 3600"
  return domain
end

def get_records(domain, host, qtype)
  query = { :domain_id => domain['_id'] }
  cursor = nil

  while true
    if qtype
      query[:name] = host ? host : ""
      query[:type] = qtype unless qtype == "ANY"
    end

    debug("using query=#{query}")
    cursor = $db['records'].find(query)
    return cursor if cursor.count > 0

    # wildcard handling (yes, it sucks)
    return [] if host == '*' or !host
    parts = host.split('.')

    # delete all previous wildcards
    parts.delete_if { |part| part == '*' }

    # delete first part of subdomain
    parts.delete_at(0)

    # and replace it with the wildcard
    parts.unshift('*')
    host = parts.join('.')
  end
end

def print_record(record, qname)
  if %w(MX SRV).include?(record['type'])
    puts "DATA\t#{qname}\tIN\t#{record['type']}\t#{record['ttl']}\t#{record['_id']}\t#{record['priority']}\t#{record['content']}"
  else
    puts "DATA\t#{qname}\tIN\t#{record['type']}\t#{record['ttl']}\t#{record['_id']}\t#{record['content']}"
  end
end

def print_records(domain, qname = nil, qtype = nil)
  return if qtype == "SOA" # already handled by print_domain

  host = qname.sub(/\.#{domain['name']}$/, '') if qname and qname != domain['name']

  debug("getting records for qname=#{qname}, qtype=#{qtype}, host=#{host}, domain=#{domain['name']}")

  get_records(domain, host, qtype).each do |record|
    print_record(record, qname)
  end

  debug("record lookup done")
end

def process_query(qname, qclass, qtype, domain_id, remote_ip)
  if qname.nil? or qclass.nil? or qtype.nil? or domain_id.nil? or remote_ip.nil?
    return failed(:incomplete_question)
  end

  if qclass != "IN"
    return failed(:invalid_qclass)
  end

  qname.downcase!

  debug("starting normal record lookup with qname=#{qname}, qtype=#{qtype}")

  domain = print_domain(qname, domain_id)
  return unless domain
  print_records(domain, qname, qtype)
end

def process_axfr(qname)
  if qname.nil? or qname.chomp.empty?
    return failed(:incomplete_question)
  end

  domain_id = qname.to_i
  debug("starting AXFR with domain_id=#{domain_id}")

  domain = print_domain(qname, domain_id)
  return unless domain
  print_records(domain)
end

def process(query)
  debug("processing query=#{query.inspect}")
  qformat, qname, qclass, qtype, domain_id, remote_ip, _ = query.split(/\t/)

  if not %w(Q AXFR).include?(qformat)
    return failed(:invalid_query)
  end

  case qformat
  when "Q"
    process_query(qname, qclass, qtype, domain_id.to_i, remote_ip)
  when "AXFR"
    process_axfr(qname)
  end

  puts "END"
  STDOUT.flush
end

STDERR.puts("starting ZenDNS backend")

ARGF.each do |query|
  if query.chomp == "HELO\t1"
    puts "OK\tZenDNS backend initialized successfully"
    STDOUT.flush
    break
  end
end

STDERR.puts("HELO ok. now processing queries")

ARGF.each do |query|
  begin
    process(query.chomp)
  rescue
    puts "END"
    STDOUT.flush
    raise
  end
end
