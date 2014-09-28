actions :create, :delete
default_action :create

attribute :source, kind_of: String, default: nil
attribute :cookbook, kind_of: String, default: nil
attribute :use, kind_of: Array, default: []

def initialize(*args)
  super
  @run_context.include_recipe("collectd")
end
