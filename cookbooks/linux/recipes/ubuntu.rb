include_recipe "apt"

%w(
  nf_conntrack
  nf_conntrack_ipv4
  nf_conntrack_ipv6
).each do |mod|
  execute "ubuntu-load-#{mod}" do
    command "/sbin/modprobe #{mod}"
    only_if { can_load_kernel_modules? }
  end
end

file "/etc/sysctl.d/10-zeropage.conf" do
  action :delete
end
