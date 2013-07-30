R&D Client - Development, the ninja way
=======================================

Overview
--------

This project is the client part letting you create and interact with unified,
optimized and highly customizable virtual machines/containers, enabling 21st
century style technologie development.

It is especially designed for Dokku (https://github.com/progrium/dokku), but
also provide a Vagrant (https://github.com/mitchellh/vagrant) RESTFul server.


Install
-------

```
$ git clone https://github.com/Gusabi/quantlab.git
$ cd quantalb && sudo ./boostrap.sh -d YOUR_DOKKU_SERVER
```

Or

```
$ export SERVERDEV_IP=your.dokku.server
$ export INSTALL_PATH=/some/where
```

```
$ wget -qO- https://raw.github.com/Gusabi/quantlab/master/bin/install-lab.sh | sudo bash
```

You're done, check the installation with:

```
$ dokuant help
```

Getting Started
---------------

First make sure you have a running dokku server, with $SERVERDEV_IP poiting to
it and $SERVERDEV_PORT = 4242.
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

Your application should be deployed and accessible; you can remotely play with
it using dokuant app <command>. Check dokuant help to see what is currently
available.
