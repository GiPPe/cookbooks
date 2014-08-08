begin
  require 'hetzner-api'

  namespace :hetzner do

    desc "reset machine"
    task :reset, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        hetzner.reset!(node[:ipaddress], :hw)
        wait_for_ssh(node[:fqdn])
      end
    end

    desc "enable rescue mode, reset machine and login"
    task :rescue, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        password = hetzner_enable_rescue_wait(node[:ipaddress])
        sshlive(args.fqdn, password)
      end
    end

    desc "enable rescue mode and reinstall"
    task :reinstall, :fqdn, :ipaddress, :profile do |t, args|
      args.with_defaults(:profile => 'generic-two-disk-md')
      password = hetzner_enable_rescue_wait(args.ipaddress)
      run_task('node:quickstart', args.fqdn, args.ipaddress, password, args.profile)
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
rescue LoadError
  $stderr.puts "Hetzner API cannot be loaded. Skipping some rake tasks ..."
end
