define :shorewall_zone, type: "ipv4" do
  node.default[:shorewall][:zones][params[:name]] = params[:type]
end
