#! /bin/bash
#
# go_box.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.

#TODO Crash if $# < 3

instruction=$1
project=$3

if [[ "$instruction" == "create" ]]; then
    git_repos="https://github.com/$2/$project"
    if [ ! -d $project ]; then
        git clone $git_repos $project
    fi

    #NOTE If there is no copy, the entire "template" process is useless
    if [ ! -f $project/Vagrantfile ]; then
        mv Vagrantfile $project
    fi
    vagrant_command="up"
elif [[ "$instruction" == "run" ]]; then
    if [ -f $project/Vagrantfile ]; then
        vagrant_command=$2
    else
        exit 1
    fi
fi

#TODO Manage different providers
#cd $2 && vagrant up --provider=lxc
cd $project

vagrant $vagrant_command
