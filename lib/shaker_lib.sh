#! /bin/bash
#
# shaker_lib.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


source "utils.sh"
source "dokuant_lib.sh"


#FIXME Always take default value
server_ip=${SERVERDEV_IP:-192.168.0.17}
server_port=${SERVERDEV_PORT:-8080}


function create_instance() {
    project=$1
    github_user=${2:-Gusabi}
    image=${3:-precise64}
    memory=${4:-1024}
    log "Requesting new dev instance for project $project (authored by $github_user)"
    log "Preparing machine $image with $memory Mb of memory..."

    result=$(http $server_ip:$server_port/dev/$project?ghuser=$github_user\&image=$image\&memory=$memory\&user=$USER)
    if [ $? != 0 ]; then
        die "Unable to contact server..."
    fi

    log "Saving identification key..."
    key=$(echo "$result" | jq '.key' | sed -e s/\"//g)
    #TODO A directory filled of keys with their associated project
    echo -e "$key" > $HOME/.box_identity_key
    chmod 600 $HOME/.box_identity_key

    ip=$(echo $result | jq '.ip' | sed -e s/\"//g)
    port=$(echo $result | jq '.port')

    log "Got ssh access ($ip:$port)"
    echo "IP=$ip" > .env
    echo "PORT=$port" >> .env
    log

    success "You are a few minutes away to hack on your box, using:"
    success "\tshaker connect $project"
}


function remote_box() {
    project=$1
    remote_command=$2
    log "Running $remote_command on project $project"

    result=$(http $server_ip:$server_port/box/$project?command=$remote_command\&user=$USER)
    if [ $? != 0 ]; then
        die "Unable to contact server..."
    fi
}


function connect() {
    source ".env"
    log "Connecting to $IP:$PORT ..."
    ssh -i $HOME/.box_identity_key vagrant@$IP -p $PORT
}


function synchronize_project() {
    #NOTE rsync or git ?
    #NOTE So an export command as well ?
    #What if no remote project yet ? provides gh_name and clone it ?
    where=$1
    project=${2:-$(get_project_name)}


    if [[ $where == "from" ]]; then
        log "Pulling from remote project $project"
        if [[ -d ".git" ]]; then
            git add -A
            git commit
            git pull $USER@$server_ip:$project
        else 
            git clone $USER@$server_ip:$project
            #FIXME did not work
            cd $project
            git remote add $project $USER@$server_ip:$project
        fi
    elif [[ $where == "to" ]]; then
        log "Pushing to remote project $project"
        git add -A
        git commit
        git push $USER@$server_ip:$project
    fi
    success "Up to date !"
}


function remote_vagrant() {
    remote_execution "cd /home/$USER/$1 && vagrant $2"
}
