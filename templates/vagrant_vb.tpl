# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = '{{ box_name }}'
    config.vm.box_url = '{{ box_uri }}'

    #config.ssh.username = '{{ username }}'
  
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", {{ memory }}, "--cpus", 2]
    end
end
