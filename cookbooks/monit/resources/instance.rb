def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create

attribute :template, :kind_of => String, :default => "monitrc"
attribute :manage, :kind_of => [TrueClass, FalseClass], :default => true
