description "base role for all nodes"

# order is very important here!
run_list(%w(
  recipe[portage]
  recipe[portage::porticron]
  recipe[base]
  recipe[openssl]
  recipe[password]
  recipe[nss::local]
  recipe[syslog::client]
  recipe[cron]
  recipe[sudo]
  recipe[ssh]
  recipe[account]
  recipe[account::hostmasters]
  recipe[postfix::satelite]
  recipe[chef::client]
  recipe[node::default]
))
