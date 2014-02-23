if gentoo?
  portage_package_use "net-analyzer/nsca" do
    use %w(minimal) unless node.role?("nagios")
  end

  package "net-analyzer/nsca"

elsif debian_based?
  package "nsca"
end

include_recipe "nagios"

template "/etc/nagios/send_nsca.cfg" do
  source "send_nsca.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0640"
end
