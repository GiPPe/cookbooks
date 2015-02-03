if mac_os_x?
  template "/usr/local/bin/install_from_app_store" do
    source "install_from_app_store"
    mode "0700"
  end

  mac_package "Xcode" do
    type "store"
    store_url "https://itunes.apple.com/de/app/xcode/id497799835"
  end

  mac_package "XQuartz" do
    type "dmg_pkg"
    package_id "org.macosforge.xquartz.pkg"
    source "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg"
    volumes_dir "XQuartz-2.7.4"
  end

  include_recipe "homebrew"

  # need to upgrade this one as early as possible or dircolors will break
  package "xz"
  package "coreutils" do
    action :upgrade
  end

  # install base packages
  node[:mac][:packages].each do |pkg|
    package pkg
  end

  include_recipe "mac::global"
  include_recipe "mac::dock"
  include_recipe "mac::finder"

  mac_userdefaults "enable safari debug menu" do
    domain "com.apple.Safari"
    key "IncludeInternalDebugMenu"
    value true
    notifies :run, "execute[kill-mac-procs]"
  end

  execute "kill-mac-procs" do
    command "killall Dock Finder SystemUIServer"
    action :nothing
  end

  include_recipe "mac::iterm"
  include_recipe "mac::chrome"

else
  raise "mac cookbook can only run on platform mac_os_x"
end
