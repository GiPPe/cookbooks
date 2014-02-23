module PlatformHelpers
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

  def guest?
    lxc? || node[:virtualization][:role] == "guest"
  end

  def vbox?
    node[:virtualization][:system] == "vbox"
  end

  def lxc?
    root? && File.read("/proc/1/environ").split("\0").any? { |env| env =~ /lxc/ }
  end

  def vbox_guest?
    vbox? && guest?
  end

  def vagrant?
    vbox_guest? && node[:cluster][:name] == "vagrant"
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
