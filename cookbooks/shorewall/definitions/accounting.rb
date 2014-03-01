define :shorewall_accounting, target: "misc", address: "-", proto: "-", port: "-" do
  node.default[:shorewall][:accounting][params[:name]] = params
end
