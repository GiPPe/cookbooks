define :splunk_input do
  name = params.delete(:name)
  node.default[:splunk][:inputs][name] = params
end
