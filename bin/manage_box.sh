#! /bin/bash
#
# go_box.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.


git_repos="https://github.com/$1/$2"

if [ ! -d $2 ]; then
    git clone $git_repos $2
fi

#NOTE If there is no copy, the entire "template" process is useless
if [ ! -f $2/Vagrantfile ]; then
    mv Vagrantfile $2
fi

#TODO Manage different providers
#cd $2 && vagrant up --provider=lxc
cd $2

vagrant up
