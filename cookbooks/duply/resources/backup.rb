actions :create, :delete
default_action :create

attribute :name, kind_of: [String], name_attribute: true
attribute :source, kind_of: String, required: true
attribute :max_full_backups, kind_of: Fixnum, default: 3
attribute :max_full_age, kind_of: Fixnum, default: 30
attribute :volume_size, kind_of: Fixnum, default: 256
