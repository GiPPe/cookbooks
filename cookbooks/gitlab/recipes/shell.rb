homedir = "/var/app/git"

%w(
  backups
  satellites
).each do |dir|
  directory "#{homedir}/#{dir}" do
    owner "git"
    group "git"
    mode "0755"
  end
end

git "#{homedir}/gitlab-shell" do
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.7.8"
end

template "#{homedir}/gitlab-shell/hooks/update" do
  source "update"
  owner "git"
  group "root"
  mode "0755"
end

template "#{homedir}/gitlab-shell/config.yml" do
  source "config.yml"
  user "git"
  group "git"
  mode "0644"
  variables({
    homedir: homedir,
  })
end

execute "gitlab-shell-install" do
  command "su -l -c 'cd #{homedir}/gitlab-shell && ./bin/install >/dev/null' git"
  user "root"
  not_if { File.exist?("#{homedir}/gitlab-shell/.installed") }
end

file "#{homedir}/gitlab-shell/.installed"
