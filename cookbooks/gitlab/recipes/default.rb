## databases
include_recipe "redis"
include_recipe "postgresql::server"

postgres_password = get_password("postgresql/gitlab")

postgresql_role "gitlab" do
  password postgres_password
  login true
end

postgresql_database "gitlab_production" do
  owner "gitlab"
end

## homedir
homedir = "/var/app/git"

deploy_skeleton "git" do
  authorized_keys_for false
end

# gitlab-shell
include_recipe "gitlab::shell"

## gitlab
%w(
  database.yml
  gitlab.yml
).each do |file|
  template "#{homedir}/shared/config/#{file}" do
    source file
    owner "git"
    group "git"
    mode "640"
    variables({
      postgres_password: postgres_password,
      homedir: homedir
    })
  end
end

directory "#{homedir}/shared/uploads" do
  owner "git"
  group "git"
  mode "0750"
end

systemd_user_session "git" do
  action :disable
end

systemd_unit "gitlab-unicorn.service" do
  template true
  variables({
    homedir: homedir,
  })
end

systemd_unit "gitlab-sidekiq.service" do
  template true
  variables({
    homedir: homedir,
  })
end

deploy_rails_application "git" do
  repository "https://github.com/gitlabhq/gitlabhq.git"
  revision "6-2-stable"

  ruby_version "ruby-2.0.0-p247"
  bundle_without %w(development test mysql)

  worker_processes node[:gitlab][:worker_processes]
  timeout node[:gitlab][:timeout]

  migrate true

  symlink_before_migrate({
    "uploads" => "public/uploads",
    "config/database.yml" => "config/database.yml",
    "config/gitlab.yml" => "config/gitlab.yml",
  })

  before_precompile do
    rvm_shell "gitlab-setup" do
      code "bundle exec rake gitlab:setup force=yes RAILS_ENV=production"
      cwd release_path
      user "git"
      not_if { File.exist?("#{homedir}/shared/.seeded") }
    end

    file "#{homedir}/shared/.seeded"
  end

  notifies :reload, "service[gitlab-unicorn]", :immediately
  notifies :restart, "service[gitlab-sidekiq]", :immediately
end

service "gitlab-unicorn" do
  action [:enable, :start]
  supports [:reload]
end

service "gitlab-sidekiq" do
  action [:enable, :start]
end

## nginx proxy
include_recipe "nginx"

ssl_certificate "/etc/ssl/nginx/gitlab" do
  cn node[:gitlab][:certificate]
end

nginx_server "gitlab" do
  template "nginx.conf"
  homedir homedir
end

## open ports
shorewall_rule "gitlab" do
  destport "http,https"
end

shorewall6_rule "gitlab" do
  destport "http,https"
end
