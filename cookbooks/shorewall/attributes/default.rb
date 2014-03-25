default[:shorewall][:accounting] = {}
default[:shorewall6][:accounting] = {}
default[:shorewall][:hosts] = {}
default[:shorewall6][:hosts] = {}
default[:shorewall][:interfaces] = {}
default[:shorewall6][:interfaces] = {}
default[:shorewall][:masq] = {}
default[:shorewall6][:masq] = {}
default[:shorewall][:policies] = {}
default[:shorewall6][:policies] = {}
default[:shorewall][:rules] = {}
default[:shorewall6][:rules] = {}
default[:shorewall][:tunnels] = {}
default[:shorewall6][:tunnels] = {}
default[:shorewall][:zones] = {}
default[:shorewall6][:zones] = {}

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
