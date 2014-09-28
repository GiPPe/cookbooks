if mac_os_x?
  mac_package "Android File Transfer" do
    source "https://dl.google.com/dl/androidjumper/mtp/current/androidfiletransfer.dmg"
  end

  tar_extract "http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20140702.zip" do
    target_dir "/Applications"
    not_if { File.exist?("/Applications/Android SDK") }
  end

  execute "mv /Applications/adt-bundle-mac-x86_64-20140702 '/Applications/Android SDK'" do
    not_if { File.exist?("/Applications/Android SDK") }
  end
end
