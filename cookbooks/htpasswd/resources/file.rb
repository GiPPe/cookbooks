actions :create, :delete
default_action :create

attribute :path, kind_of: String, name_attribute: true
attribute :owner, kind_of: String, default: "root"
attribute :group, kind_of: String, default: "root"
attribute :mode, kind_of: String, default: "0440"
attribute :users, kind_of: [Array, Hash], default: {}
