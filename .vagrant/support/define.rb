def define(name, ip)
  Vagrant.configure("2") do |config|
    config.vm.define name do |base|
      _chef = nil
      base.vm.hostname = "#{name}.vagrant.example.com"
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
      end
      yield base.vm, _chef if block_given?
      _chef.add_recipe('virtualbox::guest')
      _chef.json = _chef.json.merge({
        chef_domain: 'example.com',
      })
    end
  end
end
