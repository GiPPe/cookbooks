def define(name, ip, memory = 2.0, cpus = 1)
  Vagrant.configure("2") do |config|
    config.vm.define name do |base|
      _chef = nil
      role = JSON.load(File.read(File.expand_path("../../../roles/base.json", __FILE__)))
      chef_domain = role['default_attributes']['chef_domain']
      base.vm.hostname = "#{name}.vagrant.#{chef_domain}"
      base.vm.network "private_network", ip: ip
      base.vm.provision :chef_client do |chef|
        _chef = chef
        chef.arguments = "--force-formatter -l error"
        chef.chef_server_url = "http://10.10.10.1:3099"
        chef.validation_key_path = '.vagrant/validation.pem'
        chef.environment = "staging"
      end
      base.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = (memory * 1024).to_i
        vb.cpus = cpus
      end
      yield base.vm, _chef if block_given?
      _chef.add_recipe('virtualbox::guest')
    end
  end
end
