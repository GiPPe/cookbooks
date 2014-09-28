# ensure that system users/groups from baselayout are always correct
# (just in case somebody has given login shells to system accounts etc)
node[:baselayout][:groups].each do |name, params|
  group "#{name}-#{rrand}" do
    group_name name
    gid params[:gid]
    append true if params[:append]
    members params[:members].split(",")
  end
end

node[:baselayout][:users].each do |name, params|
  if params[:comment]
    comment = params[:comment]
  else
    comment = name
  end

  user "#{name}-#{rrand}" do
    username name
    password "*"
    uid params[:uid]
    gid params[:gid]
    comment comment
    home params[:home]
    shell params[:shell]
  end
end

user "root" do
  uid 0
  gid 0
  comment "root"
  home "/root"
  shell "/bin/bash"
  password "*" unless node.users.empty?
end

%w(/root /root/.ssh).each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0700"
  end
end

directory "/home" do
  owner "root"
  group "root"
  mode "0755"
end

# we don't want no motd
file "/etc/motd" do
  action :delete
  manage_symlink_source false
end

# make sure /etc/mtab always points to the right info
link "/etc/mtab" do
  to "/proc/self/mounts"
end

# /run compatibility (both directions)
link "/var/run" do
  to "/run"
  not_if { File.symlink?("/run") }
end

link "/var/lock" do
  to "/run/lock"
  not_if { File.symlink?("/run/lock") }
end

link "/run" do
  to "/var/run"
  not_if { File.symlink?("/var/run") }
end

link "/run/lock" do
  to "/var/lock"
  not_if { File.symlink?("/var/lock") }
end

# wrapper for systemd/openrc/sysvinit abstraction
cookbook_file "/sbin/service" do
  source "service.sh"
  owner "root"
  group "root"
  mode "0755"
  manage_symlink_source false
  force_unlink true if File.exist?("/sbin/service")
end
