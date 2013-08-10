R&D Client - Development made right
===================================

Overview
--------

This project is the client part letting you create and interact with unified,
optimized and highly customizable virtual machines/containers, enabling 21st
century style technologie development.

It is especially designed for Dokku (https://github.com/Gusabi/dokku), but
also provide a Vagrant (https://github.com/mitchellh/vagrant) RESTFul server.


Install
-------

- With Vagrant (http://www.vagrantup.com/).

```
$ git clone https://github.com/Gusabi/pencilcase.git

$ sudo apt-get install lxc redir
$ sudo apt-get update && apt-get dist-upgrade
$ vagrant plugin install vagrant-lxc
$ cd pencilcase && vagrant up --provder=lxc
```

You can use an other provider but edit eventually the Vagrantfile for fine
customization.  You can also change default base image by setting env variables BOX_NAME (and
optionnaly BOX_URI if you don't have it already on your system)

- Other installation methods let you tweak the process with env variables:

```
$ export SERVERDEV_IP=your.dokku.server
$ export SERVERDEV_PORT=7777
$ export LOGS=/tmp/pencilcase.log
$ export USER_SHELL=zsh
```

And then simply run:

```
$ git clone https://github.com/Gusabi/pencilcase.git
$ cd pencilcase && sudo -E make all
```

- Or one liner style (with more installation options):

```
$ export PROJECT_URL=Gusabi/pencilcase
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
$ pencil --version
$ pencil --help
```

Getting Started
---------------

We're going to create our remote dev environment.

First make sure you have a running dokku server, with ```$SERVERDEV_IP``` and
```$SERVERDEV_PORT``` rightly configured.

For full features, you also need a redis server and make docker to listen on your LAN
or public IP. On your server, kill docker daemon process and run:

```
dokku-server $ sudo docker -H 0.0.0.0:4243 -d &
dokku-server $ redis-server &
```

Then come back on you work station and ceate a new directory to put a ```dev.env``` file with:

```
GIT_USER=You
GIT_MAIL=you@whatever.com
shell=zsh
NODE=0.10.7
PLUGINS=t,z,autoenv,virtualenv,git-dude,git-hub,git-extras,git-scm
GITHUB_URL=    # Optionnal, install it in your env
DOTFILES_URL=  # Optionnal, use an other dotfiles repo https://github.com/Gusabi/Dotfiles
```

And just run:

```
whatever-directory $ pencil create user  # If you never dit it on this machine
your-project $ pencil create app
your-project $ pencil set image dev/multi-buildpacks  # Optionnal, will build your env from this system image
your-project $ pencil deploy
```

Your application should be deployed and accessible. You can remotely play with
it using ```$ pencil "command" --app <appname>```. Check ```$ pencil --help``` to see what is currently
available.
