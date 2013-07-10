#! /bin/bash
#
# shaker_lib.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


source "utils.sh"


server_ip='192.168.0.12'
server_port=8080


function create_instance() {
    project=$1
    log "Requesting new dev instance for project $project ..."

    result=$(http $server_ip:$server_port/dev/$project?image=quantal64\&memory=1024\&user=$USER)

    log "Saving identification key..."
    key=$(echo "$result" | jq '.key' | sed -e s/\"//g)
    #TODO A directory filled of keys with their associated project
    echo -e "$key" > $HOME/.box_identity_key

    ip=$(echo $result | jq '.ip' | sed -e s/\"//g)
    port=$(echo $result | jq '.port')

    log "Got ssh access ($ip:$port)"
    echo "IP=$ip" > .env
    echo "PORT=$port" >> .env
    log

    success "You are a few minutes away to hack on your box, using:"
    success "\tdokuant connect $project"
}

function connect() {
    source ".env"
    log "Connecting to $IP:$PORT ..."
    ssh -i $HOME/.box_identity_key vagrant@$IP -p $PORT
}
