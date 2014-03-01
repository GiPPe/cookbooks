define :shorewall_tunnel, vpntype: "openvpn", zone: nil, gateway: nil do
  node.default[:shorewall][:tunnels][params[:name]] = params
end
