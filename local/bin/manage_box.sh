#! /bin/bash
# encoding: utf-8
#
# Copyright 2013 Xavier Bruhiere
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#TODO Crash if $# < 3

instruction=$1
# $2 depends on $1
project=$3
provider=$4

if [[ "$instruction" == "create" ]]; then
    gh_user=$2
    git_repos="https://github.com/$gh_user/$project"
    if [ ! -d $project ]; then
        git clone $git_repos $project
    fi

    if [ ! -f $project/packages.txt ]; then
        cp $HOME/local/templates/packages.txt $project
    fi
    #NOTE If there is no copy, the entire "template" process is useless
    if [ ! -f $project/Vagrantfile ]; then
        mv Vagrantfile $project
    fi

    if [ -n "$provider" ]; then
        vagrant_command="up --provider=$provider"
    else
        vagrant_command="up"
    fi

elif [[ "$instruction" == "run" ]]; then
    if [ -f $project/Vagrantfile ]; then
        vagrant_command=$2

        if [[ "$vagrant_command" == "destroy" ]]; then
            vagrant_command="destroy --force"

        elif [ "$vagrant_command" == "up" -a -n "$provider" ]; then
            vagrant_command="up --provider=$provider"
        fi

    else
        exit 1
    fi
fi

#TODO Manage different providers
#cd $2 && vagrant up --provider=lxc
cd $project

#NOTE Does vagrant up wake up halted VM ?
vagrant $vagrant_command
