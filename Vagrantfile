# -*- mode: ruby -*-
# vi: set ft=ruby :

# default is cool but environment can overwrite it
BOX_NAME = ENV["BOX_NAME"] || "quantal64"
BOX_URI = ENV["BOX_URI"] || "http://dl.dropbox.com/u/13510779/lxc-quantal-amd64-2013-07-12.box"

# This syntax requires vagrant 1.2+
Vagrant.configure("2") do |config|
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI

  # More standard location to install and work
  config.vm.synced_folder File.dirname(__FILE__), "/home/vagrant/quantlab"

  config.vm.provider :lxc do |lxc|
    lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
  end

  # apt-git generic approch for bootstraping the VM
  config.vm.provision :shell, :inline => "export PROJECT_URL=Gusabi/quantlab wget -qO- https://raw.github.com/Gusabi/Dotfiles/master/utils/apt-git | bash"
end
