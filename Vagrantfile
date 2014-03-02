# -*- mode: ruby -*-
# vi: set ft=ruby :

def define(name, id)
  Vagrant.configure("2") do |config|
    config.vm.define name do |base|
      _chef = nil
      user = (ENV["USER"] || ENV["USERNAME"]).downcase.tr(" ", "-")
      base.vm.hostname = "#{name}.#{user}.vagrantup.com"
      base.vm.network "private_network", ip: "10.10.#{id/100}.#{id%100}/16"
      if File.exist?("vagrant/provision/#{name}.sh")
        base.vm.provision :shell, path: "vagrant/provision/#{name}.sh"
      end
      base.vm.provision :chef_client do |chef|
        _chef = chef
      end
      base.chef_zero.chef_repo_path = "."
      base.chef_zero.cookbooks = Dir["./cookbooks/*"] + Dir["./site-cookbooks/*"]
      base.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.customize ["modifyvm", :id, "--vrde", "on"]
        vb.customize ["modifyvm", :id, "--vrdeport", id.to_s]
        vb.customize ["modifyvm", :id, "--vrdeauthtype", "external"]
      end
      yield base.vm, _chef if block_given?
      _chef.add_recipe('virtualbox::guest')
      _chef.json = _chef.json.merge({
        cluster: {
          name: "vagrant",
        },
      })
    end
  end
end

Dir[File.dirname(__FILE__) + "/vagrant/machines/*.rb"].each { |file| require file }
