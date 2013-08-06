# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = '{{ box_name }}'
    config.vm.box_url = '{{ box_uri }}'

    #config.ssh.username = '{{ username }}'

    config.vm.provider :lxc do |lxc|
        lxc.customize 'cgroup.memory.limit_in_bytes', '{{ memory }}'
    end

    config.vm.provision "shell", path: "/home/xavier/local/templates/configure.sh"
end
