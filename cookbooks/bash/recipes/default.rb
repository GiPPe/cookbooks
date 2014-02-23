if gentoo?
  package "app-shells/bash"

elsif debian_based?
  package "bash"
  package "bash-completion"

elsif mac_os_x?
  package "bash"
  package "bash-completion"
end

directory node[:bash][:rcdir] do
  mode "0755"
end

%w(
  bash_logout
  bashcomp-modules
  bashcomp.sh
  bashrc
  color.sh
  detect.sh
  gentoo.sh
  prompt.sh
).each do |f|
  template "#{node[:bash][:rcdir]}/#{f}" do
    source f
    mode "0644"
  end
end

if root?
  template "/etc/profile" do
    source "profile"
    owner "root"
    group "root"
    mode "0644"
  end

  # always use global bashrc for root
  %w(.bashrc .bash_profile .bash_logout).each do |f|
    file "#{node[:homedir]}/#{f}" do
      action :delete
    end
  end

  # most distributions use /etc/bash.bashrc and /etc/bash.bash_logout but we
  # follow the gentoo way of putting these in /etc/bash, so we symlink these
  # for compatibility
  file "/etc/bash.bashrc" do
    action :delete
    not_if { File.symlink?("/etc/bash.bashrc") }
  end

  link "/etc/bash.bashrc" do
    to "#{node[:bash][:rcdir]}/bashrc"
  end

  file "/etc/bash.bash_logout" do
    action :delete
    not_if { File.symlink?("/etc/bash.bash_logout") }
  end

  link "/etc/bash.bash_logout" do
    to "#{node[:bash][:rcdir]}/bash_logout"
  end
else
  %w(.bashrc .bash_profile).each do |f|
    link "#{node[:homedir]}/#{f}" do
      to "#{node[:bash][:rcdir]}/bashrc"
    end
  end

  link "#{node[:homedir]}/.bash_logout" do
    to "#{node[:bash][:rcdir]}/bash_logout"
  end

  overridable_template "#{node[:homedir]}/.bashrc.local" do
    source "bashrc.local"
    cookbook "users"
    instance node[:current_user]
  end
end

# various color fixes for solarized
cookbook_file node[:bash][:dircolors] do
  source "dircolors.ansi-universal"
  mode "0644"
end

cookbook_file node[:bash][:colordiffrc] do
  source "colordiffrc"
  mode "0644"
end

# scripts
%w(
  IP
  copy
  grab
  mktar
  urlscript
).each do |f|
  cookbook_file "#{node[:script_path]}/#{f}" do
    source "scripts/#{f}"
    mode "0755"
  end
end

execute "env-update" do
  action :nothing
  only_if { gentoo? }
end
