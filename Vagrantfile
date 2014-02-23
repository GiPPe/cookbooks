# -*- mode: ruby -*-
# vi: set ft=ruby :

def define(name, id)
  Vagrant.configure("2") do |config|
    config.vm.define name do |base|
      _chef = nil
      user = (ENV["USER"] || ENV["USERNAME"]).downcase.tr(" ", "-")
      base.vm.hostname = "#{user}.#{name}.vagrantup.com"
      base.vm.network "private_network", ip: "10.10.#{id/100}.#{id%100}/16"
      if File.exist?("vagrant/provision/#{name}.sh")
        base.vm.provision :shell, path: "vagrant/provision/#{name}.sh"
      end
      base.vm.provision :chef_solo do |chef|
        _chef = chef
        chef.binary_env = "LANG=en_US.UTF-8"
        chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
        chef.data_bags_path = "data_bags"
        chef.environments_path = "environments"
        chef.environment = "staging"
        chef.roles_path = "roles"
      end
      base.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.customize ["modifyvm", :id, "--vrde", "on"]
        vb.customize ["modifyvm", :id, "--vrdeport", id.to_s]
        vb.customize ["modifyvm", :id, "--vrdeauthtype", "external"]
      end
      yield base.vm, _chef if block_given?
      _chef.add_recipe('virtualbox::guest')
      _chef.json = _chef.json.merge({
        # vagrant has 10.0.2.15 on eth0 as a NAT device which cannot be
        # reached from the host, so we add a private network and hard-code the
        # primary_ipaddress here
        primary_ipaddress: "10.10.#{id/100}.#{id%100}",
        cluster: {
          name: "vagrant",
        },
      })
    end
  end
end

Dir[File.dirname(__FILE__) + "/vagrant/machines/*.rb"].each { |file| require file }
