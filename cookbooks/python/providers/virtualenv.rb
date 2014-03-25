require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

action :create do
  unless exists?
    Chef::Log.info("Creating virtualenv #{new_resource} at #{new_resource.path}")
    execute "virtualenv --python=#{new_resource.interpreter} #{new_resource.options} #{new_resource.path}" do
      user new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
    end
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if exists?
    description = "delete virtualenv #{new_resource} at #{new_resource.path}"
    converge_by(description) do
      Chef::Log.info("Deleting virtualenv #{new_resource} at #{new_resource.path}")
      FileUtils.rm_rf(new_resource.path)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::PythonVirtualenv.new(new_resource.name)
  @current_resource.path(new_resource.path)
  if exists?
    cstats = ::File.stat(current_resource.path)
    @current_resource.owner(cstats.uid)
    @current_resource.group(cstats.gid)
  end
  @current_resource
end

private

def exists?
  ::File.exist?(current_resource.path) && ::File.directory?(current_resource.path) \
    && ::File.exists?("#{current_resource.path}/bin/activate")
end
