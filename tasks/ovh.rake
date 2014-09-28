begin
  require 'ovh/rest'

  namespace :ovh do

    desc "reset machine"
    task :reset, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        ovh_reset(node[:ipaddress])
        wait_for_ssh(node[:fqdn])
      end
    end

    desc "enable rescue mode, reset machine and login"
    task :rescue, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        ovh_enable_rescue_wait(node[:ipaddress])
        sshlive(args.fqdn)
      end
    end

    desc "enable rescue mode and reinstall"
    task :reinstall, :fqdn, :ipaddress, :profile do |t, args|
      args.with_defaults(:profile => 'generic-two-disk-md')
      ovh_enable_rescue_wait(args.ipaddress)
      sleep(10) # sleep a while so that boot scripts deploy our ssh key
      run_task('node:quickstart', args.fqdn, args.ipaddress, args.profile)
    end

    desc "set server names and reverse DNS"
    task :dns do
      search("*:*") do |node|
        fqdn = node[:fqdn]
        ip = Resolv.getaddress(fqdn)

        if ip != node[:ipaddress]
          puts "IP #{node[:ipaddress]} does not match resolved address #{ip} for FQDN #{fqdn}"
        end

        ovh_server_name_rdns(ip, fqdn)
      end
    end

  end
rescue LoadError
  $stderr.puts "OVH API cannot be loaded. Skipping some rake tasks ..."
end
