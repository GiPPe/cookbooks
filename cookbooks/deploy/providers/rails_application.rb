include AccountHelpers

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]
  rails_env = nr.rails_env || node.chef_environment

  template "#{path}/shared/config/unicorn.rb" do
    source "rails/unicorn.rb.erb"
    cookbook "deploy"
    owner user[:name]
    group user[:group][:name]
    mode "640"
    variables({
      path: path,
      worker_processes: nr.worker_processes,
      timeout: nr.timeout,
    })
  end

  deploy_ruby_application user[:name] do
    repository nr.repository
    revision nr.revision
    user nr.user

    rvm_version nr.rvm_version
    ruby_version nr.ruby_version

    force nr.force

    purge_before_symlink nr.purge_before_symlink
    symlink_before_migrate({
      "config/unicorn.rb" => "config/unicorn.rb",
    }.merge(nr.symlink_before_migrate))
    symlinks nr.symlinks

    after_bundle do
      ruby_block "#{nr.user}-before-precompile" do
        block do
          callback(:before_precompile, nr.before_precompile)
        end
      end

      rvm_shell "#{nr.user}-assets:precompile" do
        code "bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
        cwd release_path
        user nr.user
      end

      rvm_shell "#{nr.user}-db:migrate" do
        code "bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
        cwd release_path
        user nr.user
        only_if { nr.migrate }
      end
    end

    before_symlink nr.before_symlink
    before_restart nr.before_restart
  end
end
