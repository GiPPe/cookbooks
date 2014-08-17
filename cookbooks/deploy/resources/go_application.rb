actions :create
default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :repository, kind_of: String, required: true
attribute :revision, kind_of: String, default: nil
attribute :purge_before_symlink, kind_of: Array, default: []
attribute :symlink_before_migrate, kind_of: Hash, default: {}
attribute :symlinks, kind_of: Hash, default: {}
attribute :force, kind_of: [TrueClass, FalseClass], default: false

def after_make(arg=nil, &block)
  arg ||= block
  set_or_return(:after_make, arg, kind_of: [Proc, String])
end

def before_symlink(arg=nil, &block)
  arg ||= block
  set_or_return(:before_symlink, arg, kind_of: [Proc, String])
end

def before_restart(arg=nil, &block)
  arg ||= block
  set_or_return(:before_restart, arg, kind_of: [Proc, String])
end
