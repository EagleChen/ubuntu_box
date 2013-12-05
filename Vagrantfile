# -*- mode: ruby -*-
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "base"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "modules"
    puppet.options = [
      "--evaltrace",
      "--verbose",
    ]
  end

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
  end
end
