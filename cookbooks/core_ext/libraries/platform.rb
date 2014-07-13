module PlatformHelpers
  def root?
    Process.euid == 0
  end

  def production?
    node.chef_environment == "production"
  end

  def staging?
    node.chef_environment == "staging"
  end

  def development?
    node.chef_environment == "development"
  end

  def testing?
    node.chef_environment == "testing"
  end

  def linux?
    node[:os] == "linux"
  end

  def gentoo?
    node[:platform] == "gentoo"
  end

  def zentoo?
    gentoo? and node[:portage][:repo] == "zentoo"
  end

  def debian?
    node[:platform] == "debian"
  end

  def ubuntu?
    node[:platform] == "ubuntu"
  end

  def debian_based?
    debian? or ubuntu?
  end

  def mac_os_x?
    node[:platform] == "mac_os_x"
  end

  def vbox?
    node[:virtualization][:system] == "vbox" && node[:virtualization][:role] == "guest"
  end

  def lxc?
    node[:virtualization][:system] == "lxc" && node[:virtualization][:role] == "guest"
  end
end

include PlatformHelpers

class Chef
  class Recipe
    include PlatformHelpers
  end

  class Node
    include PlatformHelpers
  end

  class Resource
    include PlatformHelpers
  end
end
