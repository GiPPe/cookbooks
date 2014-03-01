define :shorewall_host, options: "-" do
  node.default[:shorewall][:hosts][params[:name]] = params
end
