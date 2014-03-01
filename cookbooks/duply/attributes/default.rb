default[:backup][:encryption_password] = 'sekrit'
default[:backup][:target_base_url] = "file:///var/backup"

default[:backup][:configs] = {}

node[:backup][:configs].each do |name, params|
  default[:backup][:configs][name][:name] = name
  default_unless[:backup][:configs][name][:max_full_backups] = 3
  default_unless[:backup][:configs][name][:max_full_age] = "1M"
  default_unless[:backup][:configs][name][:volume_size] = "25"
end
