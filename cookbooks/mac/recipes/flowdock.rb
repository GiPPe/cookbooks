mac_package "Flowdock" do
  source "https://flowdock-resources.s3.amazonaws.com/mac/Flowdock.zip"
  type "zip_app"
  only_if { mac_os_x? }
end
