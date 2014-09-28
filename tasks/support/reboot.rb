def wait_for_ssh(fqdn, login = true)
  wait_with_ping(fqdn, false)
  wait_with_ping(fqdn, true)
  print "Waiting for ssh to be accessible "
  loop do
    print "."
    system("nmap -p 22 -sT -Pn #{fqdn} | grep 'open  ssh' &> /dev/null")
    break if $?.exitstatus == 0
    sleep 5
  end
  print "\n"

  system("ssh -t #{fqdn} '/usr/bin/sudo -i uname -a'") if login
end

def reboot_wait(fqdn, login = true)
  system("ssh -t #{fqdn} '/usr/bin/sudo -i systemctl reboot'")
  wait_for_ssh(fqdn, login)
end
