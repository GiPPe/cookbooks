directory "/backup" do
  owner "root"
  group "root"
  mode "0755"
end

node.users.select do |user|
  user[:tags] and user[:tags].include?("backup")
end.each do |user|
  account_skeleton user[:id] do
    user.each do |key, value|
      next if [:id, :name].include?(key.to_sym)
      next unless respond_to?(key.to_sym)
      send(key.to_sym, value) if value
    end
    gid "backup"
    home "/backup/#{user[:id]}"
    home_owner user[:id]
    home_group "backup"
    home_mode "0711"
  end

  group "backup-#{rrand}" do
    group_name "backup"
    members user[:id]
    append true
  end

  ssh_chroot_sftp user[:id] do
    directory "/backup"
  end

  # special case for user backup:
  #
  # create directories for all hosts that want to do backup via duply since
  # duplicity does not create directories recusrively ... *sigh*
  #
  if user[:id] == "backup"
    node.nodes.each do |n|
      next unless n[:backup]
      next unless n[:backup][:configs]
      next if n[:backup][:configs].empty?

      directory "/backup/backup/#{n[:fqdn]}" do
        owner "backup"
        group "backup"
        mode "0700"
      end
    end
  end
end
