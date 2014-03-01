define :shorewall_interface, interface: nil do
  node.default[:shorewall][:interfaces][params[:name]] = params[:interface]
end
