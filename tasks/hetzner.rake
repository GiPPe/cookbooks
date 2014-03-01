# remote commands for maintenance

require 'ap'
require 'irb'
require 'ripl'

class HetznerConsole
  def initialize
    Ripl.start(binding: binding)
  end

  def method_missing(name, *args, &block)
    if hetzner.respond_to?(name)
      hetzner.send(name, *args, &block)
    else
      super
    end
  end
end

namespace :hetzner do

  desc "open hetzner console"
  task :console do |t, args|
    HetznerConsole.new
  end

  desc "reset machine via Hetzner Robot"
  task :reset, :fqdn do |t, args|
    search("fqdn:#{args.fqdn}") do |node|
      hetzner.reset!(node[:ipaddress], :hw)
      wait_for_ssh(node[:fqdn])
    end
  end

  desc "enable rescue and login"
  task :rescue, :fqdn do |t, args|
    search("fqdn:#{args.fqdn}") do |node|
      password = hetzner_enable_rescue_wait(node[:ipaddress])
      system(%{sshpass -p #{password} ssh -l root -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "GlobalKnownHostsFile /dev/null" #{args.fqdn}})
    end
  end

  desc "enable rescue and rebootstrap"
  task :reinstall, :fqdn, :ipaddress, :profile do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')
    password = hetzner_enable_rescue_wait(args.ipaddress)
    Rake::Task['node:quickstart'].reenable
    Rake::Task['node:quickstart'].invoke(args.fqdn, args.ipaddress, password, args.profile)
  end

  desc "Set server names and reverse DNS"
  task :dns do
    search("*:*") do |node|
      fqdn = node[:fqdn]
      ip = Resolv.getaddress(fqdn)

      if ip != node[:ipaddress]
        puts "IP #{node[:ipaddress]} does not match resolved address #{ip} for FQDN #{fqdn}"
      end

      hetzner_server_name_rdns(ip, fqdn)
    end
  end

end
