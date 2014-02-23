def check_ping(ipaddress)
  reachable = nil

  begin
    sh("ping -c 1 #{detect_os == :macosx ? "-W" : "-w"} 5 #{ipaddress} &>/dev/null")
    reachable = true
    sleep(1)
  rescue
    reachable = false
  end

  return reachable
end

def wait_with_ping(ipaddress, reachable)
  print "Waiting for machine to #{reachable ? "boot" : "shutdown"} "

  while check_ping(ipaddress) != reachable
    print "."
  end

  print "\n"
end
