# -*- mode: ruby -*-
# vi: set ft=ruby :

projectroot = File.dirname(__FILE__)

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "file", source: projectroot + "/bootstrap", destination: "~/bootstrap"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.network "forwarded_port", guest: 33254, host: 8080
  config.vm.provider "virtualbox" do |v|
        v.memory = 8192
        v.cpus = 4
    end
end
