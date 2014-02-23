actions :create, :delete
default_action :create

attribute :service, kind_of: [String], name_attribute: true
attribute :schedule, kind_of: [String, Array], required: true
attribute :unit, kind_of: [String, Hash], default: nil
