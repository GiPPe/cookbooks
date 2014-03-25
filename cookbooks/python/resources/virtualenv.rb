actions :create, :delete
default_action :create

attribute :path, kind_of: String, name_attribute: true
attribute :interpreter, default: 'python'
attribute :owner, regex: Chef::Config[:user_valid_regex]
attribute :group, regex: Chef::Config[:group_valid_regex]
attribute :options, kind_of: String
