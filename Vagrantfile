Vagrant.require_plugin "vagrant-systemd"
Vagrant.require_plugin "vagrant-zentoo"
Vagrant.require_plugin "vagrant-vbguest"

Dir[File.dirname(__FILE__) + "/.vagrant/support/*.rb"].each { |file| require file }

define("zentoo-base", "10.10.10.2/24") do |vm, chef|
  vm.box = "zentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box"
  chef.add_role("base")
end

define("gentoo-base", "10.10.10.3/24") do |vm, chef|
  vm.box = "gentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/gentoo/amd64/gentoo-amd64-base.box"
  chef.add_role("base")
end

define("debian-base", "10.10.10.4/24") do |vm, chef|
  vm.box = "debian-7.1.0-amd64-base"
  vm.box_url = "http://mirror.zenops.net/debian/amd64/debian-7.1.0-amd64-base.box"
  chef.add_role("base")
end

define("ubuntu-base", "10.10.10.5/24") do |vm, chef|
  vm.box = "ubuntu-12.04.3-amd64-base"
  vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04.3-amd64-base.box"
  chef.add_role("base")
end

define("chef", "10.10.10.10/24") do |vm, chef|
  vm.box = "ubuntu-12.04.3-amd64-base"
  vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04.3-amd64-base.box"
  chef.add_role("base")
  chef.add_role("chef")
end

define("nagios", "10.10.10.11/24") do |vm, chef|
  vm.box = "zentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box"
  chef.add_role("base")
  chef.add_role("nagios")
  chef.add_role("mx")
end

define("lab", "10.10.10.12/24") do |vm, chef|
  vm.box = "zentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box"
  chef.add_role("base")
  chef.add_role("gitlab")
end

# vim: ft=ruby
