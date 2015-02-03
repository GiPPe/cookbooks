mac_package "Cloud" do
  source "http://downloads.getcloudapp.com/mac/CloudApp-2.0.2.zip"
  type "zip_app"
  only_if { mac_os_x? }
end
