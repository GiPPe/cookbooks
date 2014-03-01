require 'resolv'

task :pull do
  unless ENV.include?('BOOTSTRAP')
    sh("git checkout -q master")
    sh("git pull -q")
  end
end

namespace :node do

  task :checkdns, :fqdn, :ipaddress do |t, args|
    ip = Resolv.getaddress(args.fqdn)
    if ip != args.ipaddress
      raise "IP #{args.ipaddress} does not match resolved address #{ip} for FQDN #{args.fqdn}"
    end
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress do |t, args|
    ENV['BATCH'] = "1"
    ENV['DISTRO'] ||= "gentoo"
    run_task('node:checkdns', args.fqdn, args.ipaddress)
    run_task('ssl:do_cert', args.fqdn)
    knife :bootstrap, [args.fqdn, "--distro", ENV['DISTRO'], "-P", "tux"]
    run_task('node:updateworld', args.fqdn) unless ENV['NO_UPDATEWORLD']
  end

  desc "Update node packages"
  task :updateworld, :fqdn do |t, args|
    env = "/usr/bin/env UPDATEWORLD_DONT_ASK=1" if ENV['BATCH']
    system("ssh -t #{args.fqdn} '/usr/bin/sudo -i #{env} /usr/local/sbin/updateworld'")
    reboot_wait(args.fqdn) if ENV['REBOOT']
  end

  desc "Quickstart & Bootstrap the specified node"
  task :quickstart, :fqdn, :ipaddress, :password, :profile do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')
    raise "missing parameters!" unless args.fqdn && args.ipaddress && args.password

    # create DNS/rDNS records
    hetzner_server_name_rdns(args.ipaddress, args.fqdn)
    zendns_add_record(args.fqdn, args.ipaddress)
    run_task('node:checkdns', args.fqdn, args.ipaddress)

    # quick start
    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'quickstart.sh')))

    tmpfile = Tempfile.new('quickstart')
    tmpfile.write(erb.result(b))
    tmpfile.rewind

    sh(%{cat #{tmpfile.path} | sshpass -p #{args.password} ssh -l root -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "GlobalKnownHostsFile /dev/null" #{args.ipaddress} "bash -s"})

    tmpfile.unlink

    # wait until machine is up again
    wait_with_ping(args.ipaddress, false)
    wait_with_ping(args.ipaddress, true)

    # run normal bootstrap
    ENV['REBOOT'] = "1"
    run_task('node:bootstrap', args.fqdn, args.ipaddress)
  end

  desc "Delete node, rename host and bootstrap again"
  task :rename, :old, :fqdn do |t, args|
    ipaddress = Resolv.getaddress(args.old)
    hetzner_server_name_rdns(ipaddress, args.fqdn)
    zendns_add_record(args.fqdn, ipaddress)
    run_task('node:checkdns', args.fqdn, ipaddress)

    sh("ssh #{args.old} sudo rm -f /etc/chef/client.pem /etc/chef/client.rb")
    sh("echo root:tux | ssh #{args.old} sudo chpasswd")
    sh("ssh #{args.old} sudo sed -i -e '/PasswordAuthentication/s/no/yes/g' /etc/ssh/sshd_config")
    sh("ssh #{args.old} sudo sed -i -e '/PermitRootLogin/s/no/yes/g' /etc/ssh/sshd_config")
    sh("ssh #{args.old} sudo systemctl reload sshd")

    ENV['NO_UPDATEWORLD'] = "1"
    run_task('node:bootstrap', args.fqdn, ipaddress)
    run_task('node:delete', args.old)
  end

  desc "Delete the specified node, client key and SSL certificates"
  task :delete, :fqdn do |t, args|
    fqdn = args.fqdn
    ENV['BATCH'] = "1"
    run_task('ssl:revoke', fqdn) rescue nil
    File.unlink(File.join(TOPDIR, "nodes", "#{fqdn}.json")) rescue nil
    knife :delete, ['-y', "nodes/#{fqdn}.json", "clients/#{fqdn}.json"] rescue nil
  end

end
