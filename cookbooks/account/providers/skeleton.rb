def whyrun_supported?
  true
end

use_inline_resources

action :create do
  nr = new_resource

  home = nr.home
  home ||= "/home/#{nr.login}"

  home_owner = nr.home_owner
  home_owner ||= nr.login

  home_group = nr.home_group
  home_group ||= nr.gid

  key_source = nr.key_source

  group nr.gid do
    append true
  end

  user nr.login do
    uid nr.uid
    gid nr.gid
    shell nr.shell
    comment nr.comment
    password nr.password
    home home
  end

  nr.groups.each do |name|
    group name do
      members nr.login
      append true
    end
  end

  directory "/home" do
    path ::File.dirname(home)
    owner "root"
    group "root"
    mode "0755"
    recursive true
  end

  directory home do
    owner home_owner
    group home_group
    mode nr.home_mode
  end

  directory "#{home}/.ssh" do
    owner home_owner
    group home_group
    mode "0700"
  end

  if key_source
    cookbook_file "#{home}/.ssh/id_rsa" do
      source key_source
      owner home_owner
      group home_group
      mode "0600"
    end

    cookbook_file "#{home}/.ssh/id_rsa.pub" do
      source "#{key_source}.pub"
      owner home_owner
      group home_group
      mode "0644"
    end
  end

  # don't create an authorized keys file if authorized_keys is nil.
  # if it's empty -- i.e. [] -- then we would create an empty
  # authorized keys but with nil, the file is not created.
  if nr.authorized_keys || nr.authorized_keys_for
    authorized_keys = authorized_keys_for(nr.authorized_keys_for)
    authorized_keys += [nr.authorized_keys].flatten.compact

    file "#{home}/.ssh/authorized_keys" do
      content(authorized_keys.sort.uniq.join("\n") + "\n")
      owner home_owner
      group home_group
      mode "0600"
    end
  end
end

action :delete do
  nr = new_resource

  home = nr.home
  home ||= "/home/#{nr.login}"

  directory home do
    action :delete
    recursive true
  end

  user nr.login do
    action :remove
  end
end

def authorized_keys_for(users)
  users = [users].flatten.compact.map do |u|
    u.to_sym
  end
  node.users.select do |u|
    users.include?(u[:id].to_sym) &&
      u[:authorized_keys] &&
      !u[:authorized_keys].empty?
  end.map do |u|
    u[:authorized_keys]
  end.flatten
end
