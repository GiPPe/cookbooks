# remote commands for maintenance

namespace :zendns do

  desc "Add missing entries to ZenDNS"
  task :update do
    search("*:*") do |node|
      fqdn = node[:fqdn]
      ip = node[:ipaddress]
      zendns_add_record(fqdn, ip)
    end
  end

end
