if root?
  include_recipe "linux::baselayout"
  include_recipe "linux::locales"
  include_recipe "linux::resolv"
  include_recipe "systemd"
  include_recipe "linux::sysctl"
  include_recipe "linux::#{node[:platform]}"
  include_recipe "linux::packages"
  include_recipe "linux::nagios"

  cron_daily "xfs_fsr" do
    command "/usr/sbin/xfs_fsr -t 600"
    action :delete
  end
end
