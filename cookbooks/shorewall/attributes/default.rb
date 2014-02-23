default[:skip][:shorewall] = vbox_guest?

set_unless[:shorewall][:hosts] = {}
set_unless[:shorewall6][:hosts] = {}
set_unless[:shorewall][:interfaces] = {}
set_unless[:shorewall6][:interfaces] = {}
set_unless[:shorewall][:masq] = {}
set_unless[:shorewall6][:masq] = {}
set_unless[:shorewall][:policies] = {}
set_unless[:shorewall6][:policies] = {}
set_unless[:shorewall][:rules] = {}
set_unless[:shorewall6][:rules] = {}
set_unless[:shorewall][:tunnels] = {}
set_unless[:shorewall6][:tunnels] = {}
set_unless[:shorewall][:zones] = {}
set_unless[:shorewall6][:zones] = {}

# detect bridge device
begin
  link = %x(ip link show)
         .split(/\n/)
         .select { |line| line =~ /master #{node[:network][:default_interface]}/ }
         .map { |line| line.split[1].sub(/:$/, '') }
         .reject { |device| device =~ /^veth/ }
rescue
  link = []
end

case link.size
when 0
  default[:network][:default_interface_bridged] = false
else
  default[:network][:default_interface_bridged] = link.first
end
