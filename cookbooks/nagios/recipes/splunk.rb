package "dev-ruby/nokogiri"

template "/usr/lib/nagios/plugins/check_splunk" do
  source "check_splunk.rb"
  owner "root"
  group "nagios"
  mode "0750"
  variables({
    master: splunk6_master_node,
    search: splunk6_search_nodes.first,
  })
end
