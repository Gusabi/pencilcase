QuantLab: R&D Client - Development, the ninja way
=================================================

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
$ > git clone https://github.com/Gusabi/quantlab.git
$ > cd quantalb && ./boostrap.sh -e YOUR_DOKKU_SERVER
```

Or

```
$ > export $SERVERDEV_IP=your.dokku.server
$ > export $INSTALL_PATH=/some/where
```

```
$ > wget -o log.txt -O - https://raw.github.com/Gusabi/quantlab/master/bin/install-lab.sh | sudo bash
```

You're done, check the installation with:

```
$ > dokuant help
```
