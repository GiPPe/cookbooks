def whyrun_supported?
  true
end

use_inline_resources

action :create do
  nr = new_resource

  users = node.users.select(&nr.query).map do |user|
    [user[:id], user[nr.password_field]]
  end

  htpasswd_file nr.path do
    owner nr.owner
    group nr.group
    mode nr.mode
    users users
  end
end

action :delete do
  nr = new_resource

  htpasswd_file nr.path do
    action :delete
  end
end
