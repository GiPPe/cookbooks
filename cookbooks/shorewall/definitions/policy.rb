define :shorewall_policy, source: nil, dest: nil, policy: nil do
  node.default[:shorewall][:policies][params[:name]] = params
end
