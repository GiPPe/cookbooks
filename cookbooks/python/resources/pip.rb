actions :install, :upgrade, :remove, :purge
default_action :install

attribute :package_name, kind_of: String, name_attribute: true
attribute :version, default: nil
attribute :timeout, default: 900
attribute :virtualenv, kind_of: String
attribute :user, regex: Chef::Config[:user_valid_regex]
attribute :group, regex: Chef::Config[:group_valid_regex]
attribute :options, kind_of: String, default: ''
