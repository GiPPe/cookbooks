if gentoo?
  package "net-ftp/ncftp"
  package "app-backup/duply"
elsif debian_based?
  package "ncftp"
  package "duply"
end

%w(
  /etc/duply
  /var/tmp/backup
  /var/cache/backup
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0700"
  end
end

node.default[:lftp][:bookmarks][:backup] = node[:backup][:target_base_url].sub(/^ssh:/, "sftp:")
