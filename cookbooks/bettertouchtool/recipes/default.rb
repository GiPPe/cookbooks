if platform?("mac_os_x")
  mac_package "BetterTouchTool" do
    source "http://www.bettertouchtool.net/BetterTouchTool.zip"
    zip true
  end
end