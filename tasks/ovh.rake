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
    run_task('ovh:quickstart', args.fqdn, args.ipaddress, args.profile)
  end

  desc "quickstart & bootstrap machine"
  task :quickstart, :fqdn, :ipaddress, :profile do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')
    raise "missing parameters!" unless args.fqdn && args.ipaddress

    # create DNS/rDNS records
    ovh_server_name_rdns(args.ipaddress, args.fqdn)
    zendns_add_record(args.fqdn, args.ipaddress)
    run_task('node:checkdns', args.fqdn, args.ipaddress)

    # quick start
    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'quickstart.sh')))
    tmpfile = Tempfile.new('quickstart')
    tmpfile.write(erb.result(b))
    tmpfile.rewind
    sshlive(args.ipaddress, nil, tmpfile.path)
    tmpfile.unlink

    # wait until machine is up again
    wait_with_ping(args.ipaddress, false)
    wait_with_ping(args.ipaddress, true)

    # run normal bootstrap
    ENV['REBOOT'] = "1"
    run_task('node:bootstrap', args.fqdn, args.ipaddress)
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
