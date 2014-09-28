include_recipe "java"

deploy_skeleton "camus"

deploy_application "camus" do
  repository node[:camus][:git][:repository]
  revision node[:camus][:git][:revision]

  before_symlink do
    execute "mvn-clean-package" do
      command "/usr/bin/mvn clean package -DskipTests=true"
      cwd release_path
      user "camus"
      group "camus"
    end
  end
end

directory "/etc/camus" do
  owner "camus"
  group "camus"
  mode "0755"
end

template "/etc/camus/camus.properties" do
  source "camus.properties"
  owner "root"
  group "root"
  mode "0644"
end

template "/var/app/camus/bin/camus" do
  source "camus.sh"
  owner "camus"
  group "camus"
  mode "0755"
end

systemd_unit "camus.service" do
  template true
end

systemd_timer "camus" do
  schedule %w(OnBootSec=60 OnUnitInactiveSec=300)
end
