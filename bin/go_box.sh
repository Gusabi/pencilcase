#! /bin/bash
#
# go_box.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


git_repos="https://github.com/$1/$2"

git clone $git_repos $2

#NOTE If there is no copy, the entire "template" process is useless
if [ ! -f $2/Vagrantfile ]; then
    cp Vagrantfile $2
fi

#TODO Manage different providers
#cd $2 && vagrant up --provider=lxc
cd $2 && vagrant up
