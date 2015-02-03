mac_package "OmniDiskSweeper" do
  source "http://www.omnigroup.com/download/latest/OmniDiskSweeper"
  accept_eula true
  only_if { mac_os_x? }
end
