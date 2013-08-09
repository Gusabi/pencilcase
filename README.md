R&D Client - Development made right
===================================

Overview
--------

This project is the client part letting you create and interact with unified,
optimized and highly customizable virtual machines/containers, enabling 21st
century style technologie development.

It is especially designed for Dokku (https://github.com/progrium/dokku), but
also provide a Vagrant (https://github.com/mitchellh/vagrant) RESTFul server.


Install
-------

- With Vagrant (http://www.vagrantup.com/).

```
$ git clone https://github.com/Gusabi/quantlab.git

$ sudo apt-get install lxc redir
$ sudo apt-get update && apt-get dist-upgrade
$ vagrant plugin install vagrant-lxc
$ cd quantlab && vagrant up --provder=lxc
```

You can use an other provider but edit eventually the Vagrantfile for fine
customization.  You can also change default base image by setting env variables BOX_NAME (and
optionnaly BOX_URI if you don't have it already on your system)

- Other installation methods let you tweak the process with env variables:

```
$ export SERVERDEV_IP=your.dokku.server
$ export SERVERDEV_PORT=7777
$ export LOGS=/tmp/quantlab.log
```

And then simply run:

```
$ git clone https://github.com/Gusabi/quantlab.git
$ cd quantlab && sudo -E make all
```

- Or one liner style (with more installation options):

```
$ export PROJECT_URL=Gusabi/quantlab
$ export INSTALL_PATH=/some/where
$ export MAKE_TARGET=all
$ export VIRTUALIZE=true
$ export PROVIDER=lxc
```

And shoot:

```
$ wget -qO- https://raw.github.com/Gusabi/Dotfiles/master/bin/apt-git | sudo -E bash
```

You're done, check the installation with:

```
$ dokuant help
```

Getting Started
---------------

First make sure you have a running dokku server, with ```$SERVERDEV_IP``` and
```$SERVERDEV_PORT``` rightly configured.

If you want to use docker client, you also need to make docker listen on your LAN
or public IP. On your server, kill docker daemon process and run:

```
dokku-server $ sudo docker -H 192.168.0.17:4242 -H 127.0.0.1:4243 -d &
```

Then create a new project, say for example heroku python sample app, and run the
following commands.

```
your-project $ dokuant create-user  # If you never dit it on this machine
your-project $ dokuant create-app
```

Hack on your project, eventually edit the Procfile to specifie how to deploy
your app. If no Procfile is provided, it will fall back to a default one.

```
your-project $ dokuant deploy
```

Your application should be deployed and accessible. You can remotely play with
it using ```$ dokuant app "command"```. Check ```$ dokuant help``` to see what is currently
available.
