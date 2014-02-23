include AccountHelpers

use_inline_resources

action :create do
  user = get_user(new_resource.user)
  path = "#{user[:dir]}/.config/systemd/user/#{new_resource.unit}"

  execute "systemd-reload-#{user[:name]}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user daemon-reload' #{user[:name]}}
    action :nothing
    only_if { systemd_running? }
  end

  if new_resource.template
    template path do
      source new_resource.unit
      variables new_resource.variables if new_resource.variables
      cookbook new_resource.cookbook if new_resource.cookbook
      owner user[:name]
      group user[:group][:name]
      mode "0644"
      notifies :run, "execute[systemd-reload-#{user[:name]}]", :immediately
    end
  else
    cookbook_file path do
      source new_resource.unit
      cookbook new_resource.cookbook if new_resource.cookbook
      owner user[:name]
      group user[:group][:name]
      mode "0644"
      notifies :run, "execute[systemd-reload-#{user[:name]}]", :immediately
    end
  end
end

action :delete do
  user = get_user(new_resource.user)
  path = "#{user[:dir]}/.config/systemd/user/#{new_resource.unit}"

  execute "systemd-reload-#{user[:name]}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user daemon-reload' #{user[:name]}}
    action :nothing
    only_if { systemd_running? }
  end

  cookbook_file path do
    action :delete
    notifies :run, "execute[systemd-reload-#{user[:name]}]", :immediately
  end
end

action :start do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-start-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user start #{new_resource.unit}' #{user[:name]}}
    not_if  %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user is-active #{new_resource.unit}' #{user[:name]}}
  end
end

action :stop do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-stop-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user stop #{new_resource.unit}' #{user[:name]}}
    only_if %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user is-active #{new_resource.unit}' #{user[:name]}}
  end
end

action :restart do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-restart-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user restart #{new_resource.unit}' #{user[:name]}}
  end
end

action :reload do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-reload-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user reload #{new_resource.unit}' #{user[:name]}}
  end
end

action :enable do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-enable-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user enable #{new_resource.unit}' #{user[:name]}}
    not_if  %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user is-enabled #{new_resource.unit}' #{user[:name]}}
  end
end

action :disable do
  user = get_user(new_resource.user)

  execute "systemd-user-unit-disable-#{user[:name]}-#{new_resource.unit}" do
    command %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user disable #{new_resource.unit}' #{user[:name]}}
    only_if %{su -l -c 'env XDG_RUNTIME_DIR="/run/user/#{user[:uid]}" systemctl --user is-enabled #{new_resource.unit}' #{user[:name]}}
  end
end
