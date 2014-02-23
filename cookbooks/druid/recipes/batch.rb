include_recipe "druid"

deploy_skeleton "dumbo"

# this relies on /etc/druid/dumbo.conf to be written somewhere else
deploy_ruby_application "dumbo" do
  repository node[:dumbo][:git][:repository]
  revision node[:dumbo][:git][:revision]
  ruby_version "ruby-1.9.3-p448"
end

template "/var/app/dumbo/bin/dumbo-runner.sh" do
  source "dumbo-runner.sh"
  owner "root"
  group "dumbo"
  mode "0654"
end

template "/var/app/dumbo/bin/batch-druid-job.sh" do
  source "batch-druid-job.sh"
  owner "root"
  group "dumbo"
  mode "0654"
end

systemd_unit "druid-dumbo.service" do
  template true
end

systemd_timer "druid-dumbo" do
  schedule %w(OnBootSec=60 OnUnitInactiveSec=300)
end
