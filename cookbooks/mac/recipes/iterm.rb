if mac_os_x?
  mac_package "iTerm" do
    source "http://www.iterm2.com/downloads/stable/iTerm2_v1_0_0.zip"
    type "zip_app"
  end

  execute "fc-cache-menlo-powerline" do
    command "/opt/X11/bin/fc-cache"
    action :nothing
  end

  cookbook_file "#{node[:homedir]}/Library/Fonts/Menlo-Powerline.otf" do
    source "Menlo+Regular+for+Powerline.otf"
    notifies :run, "execute[fc-cache-menlo-powerline]", :immediately
  end

  execute "iterm-solarized-dark-open" do
    command "open '/Applications/iTerm.app/Solarized Dark.itermcolors'"
    action :nothing
  end

  remote_file "/Applications/iTerm.app/Solarized Dark.itermcolors" do
    source "https://raw.github.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors"
    notifies :run, "execute[iterm-solarized-dark-open]", :immediately
  end

  execute "iterm-solarized-light-open" do
    command "open '/Applications/iTerm.app/Solarized Light.itermcolors'"
    action :nothing
  end

  remote_file "/Applications/iTerm.app/Solarized Light.itermcolors" do
    source "https://raw.github.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Light.itermcolors"
    notifies :run, "execute[iterm-solarized-light-open]", :immediately
  end

  mac_userdefaults "hide tab bar when there is only one tab" do
    domain "com.googlecode.iterm2"
    key "HideTab"
    value "1"
  end

  mac_userdefaults "hide border around window" do
    domain "com.googlecode.iterm2"
    key "UseBorder"
    value "0"
  end
end
