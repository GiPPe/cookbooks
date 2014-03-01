define :shorewall_masq, interface: nil, source: nil do
  node.default[:shorewall][:masq][params[:name]] = params
end
