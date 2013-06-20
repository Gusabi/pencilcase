#! /bin/bash
#
# boostrap.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#

set -e
clear


source utils.sh


function usage() {
    #TODO
    log "Usage: $0 command"
}


#TODO Much better check
if [ $# -lt 1 ]; then
    usage
    die "Insufficient number of args, exiting..."
fi


IP="192.168.0.17"
HOSTNAME="192.168.0.17"
PROJECT=$2


function init_workspace() {
    log "Initiating worspace repository"
    git init
    git add -A
    git commit -m "Initial commit"

    #FIXME 
    #log "Setting up remote deployment"
    #mina setup -v
}


function create_dokku_user() {
    log "Creating $1 account"
    #TODO generate id_rsa.pub
    #FIXME root password needed !!
    cat ~/.ssh/id_rsa.pub | ssh root@$HOSTNAME "gitreceive upload-key $1"
}


function create_dokku_app() {
    #NOTE Python by heroku: https://devcenter.heroku.com/articles/python
    if [[ $(ls -al | grep *.py) != "" ]]; then
        virtualenv venv --distribute --no-site-packages
        source venv/bin/activate
        echo "venv" >> .gitignore
        echo "*.pyc" >> .gitignore
        #NOTE Parse *.py files and pip install them ? then pip freeze, etc...
    fi

    #TODO Automatic creation when first deployment ?
    log "Creating application $2 on $1 account"
    git remote add $1 git@$HOSTNAME:$2

    log "Now create at least a Procfile (for help, visit http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)"
}


function deploy_dokku_app() {
    git push $1 master
}


if [ $1 == "create_user" ]; then
    create_dokku_user $USER

elif [ $1 == "create_app" ]; then
    #FIXME If directory clean, stop after initiating git
    init_workspace
    create_dokku_app $USER $PROJECT

elif [ $1 == "deploy" ]; then
    deploy_dokku_app $USER

else
    fail "Unknow command"
fi

success "Done"
