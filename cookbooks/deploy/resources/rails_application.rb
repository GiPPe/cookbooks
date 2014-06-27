actions :create
default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :repository, kind_of: String, required: true
attribute :revision, kind_of: String, default: nil
attribute :rvm_version, kind_of: String
attribute :ruby_version, kind_of: String, required: true
attribute :purge_before_symlink, kind_of: Array, default: []
attribute :symlink_before_migrate, kind_of: Hash, default: {}
attribute :symlinks, kind_of: Hash, default: {}
attribute :bundle_without, kind_of: [Array, String], default: %w(development test)
attribute :force, kind_of: [TrueClass, FalseClass], default: false
attribute :migrate, kind_of: [TrueClass, FalseClass], default: false
attribute :worker_processes, kind_of: Fixnum, default: 4
attribute :timeout, kind_of: Fixnum, default: 30
attribute :rails_env, kind_of: String, default: nil
attribute :asset_pipeline, kind_of: [TrueClass, FalseClass], default: true

def before_precompile(arg=nil, &block)
  arg ||= block
  set_or_return(:before_precompile, arg, kind_of: [Proc, String])
end

def before_symlink(arg=nil, &block)
  arg ||= block
  set_or_return(:before_symlink, arg, kind_of: [Proc, String])
end

def before_restart(arg=nil, &block)
  arg ||= block
  set_or_return(:before_restart, arg, kind_of: [Proc, String])
end
