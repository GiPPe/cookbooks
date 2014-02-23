def whyrun_supported?
  true
end

use_inline_resources

action :create do
  nr = new_resource

  content = nr.users.map do |login, password|
    "#{login}:#{password}"
  end.sort.join("\n")

  file nr.path do
    content content
    owner nr.owner
    group nr.group
    mode nr.mode
  end
end

action :delete do
  nr = new_resource

  file nr.path do
    action :delete
  end
end
