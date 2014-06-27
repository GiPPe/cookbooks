include_recipe "hadoop2::cli"

deploy_skeleton "hive"

deploy_application "hive" do
  repository node[:hadoop2][:hive][:repository]
  revision node[:hadoop2][:hive][:revision]

  before_symlink do
    execute "mvn-clean-install" do
      command "/usr/bin/mvn clean install -Phadoop-2,dist -DskipTests=true"
      cwd release_path
      user "hive"
      group "hive"
    end
  end
end

link "/var/app/hive/dist" do
  to Dir["/var/app/hive/current/packaging/target/*bin/*bin"][0]
end

execute "env-update" do
  action :nothing
  only_if { gentoo? }
end

template "/etc/env.d/98hive" do
  source "98hive"
  owner "root"
  group "root"
  mode 0644
  notifies :run, 'execute[env-update]'
end
