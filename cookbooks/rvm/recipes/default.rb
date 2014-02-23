if gentoo?
  # portage package provider will take care of using sudo
  package "dev-ruby/rvm" do
    action :nothing
  end.run_action(:install)
else
  # omnibus ruby
  chef_gem 'rvm' do
    action :install
    options "--user-install" if !root?
  end
end

Gem.clear_paths

require 'rvm'

create_rvm_shell_chef_wrapper
create_rvm_chef_user_environment

if !root?
  rvm_instance node[:current_user]
end
