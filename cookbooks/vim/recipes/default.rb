if gentoo?
  package "app-editors/vim"
  package "dev-util/ctags"

elsif debian_based?
  package "vim"
  package "exuberant-ctags"

elsif mac_os_x?
  package "vim"
  package "ctags"
end

directory node[:vim][:rcdir] do
  mode "0755"
end

template node[:vim][:rcfile] do
  source "vimrc"
  mode "0644"
end

file "#{node[:vim][:rcdir]}/autoload/pathogen.vim" do
  action :delete
end

file "#{node[:vim][:rcdir]}/cleanup_bundle" do
  action :delete
end

if root?
  directory "#{node[:vim][:rcdir]}/bundle" do
    action :delete
    recursive true
  end
else
  directory "#{node[:vim][:rcdir]}/bundle" do
    recursive true
  end

  git "#{node[:vim][:rcdir]}/bundle/neobundle.vim" do
    repository "https://github.com/Shougo/neobundle.vim"
    reference "master"
    action :checkout
  end

  overridable_template "#{node[:homedir]}/.vimrc.local" do
    source "vimrc.local"
    cookbook "users"
    instance node[:current_user]
  end
end
