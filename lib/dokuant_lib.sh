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


# Docker server informations
server_ip=${SERVERDEPLOY_IP:-192.168.0.17}
server_port=${SERVERDEPLOY_PORT:-4242}


# Most of the commands assume project name == root directory name
function get_project_name() {
    pwd | awk -F"/" '{print $NF}'
}


# Git push use ssh key identification
function create_dokku_user() {
    username=$1

    if [ ! -f id_rsa.pub ]; then
        log "No public key found, creating a new one:"
        ssh-keygen
    fi

    # Server root password required
    log "Creating $username account"

    # Uploading key to the server
    cat ~/.ssh/id_rsa.pub | ssh root@$server_ip "gitreceive upload-key $1"
}


function create_dokku_app() {
    username=$1
    project=$2
    #NOTE Python by heroku: https://devcenter.heroku.com/articles/python
    log "Initializing Dokku application"

    log "Setting up git workspace"
    if [ ! -d ".git" ]; then
        # No git repos here, initialize it
        git init
    fi
    #FIXME If nothing to do, will stop. rm .git above ?
    git add -A
    git commit -m "Initial commit"

    if is_python; then
        log "Python app detected"
        log "Creating virtual environment"
        virtualenv venv --distribute --no-site-packages
        #FIXME Activates nothing
        source ./venv/bin/activate
        echo "venv" >> .gitignore
        echo "*.pyc" >> .gitignore
        #NOTE Parse *.py files and pip install them ? then pip freeze, etc...
    fi

    #TODO Automatic creation when first deployment ?
    log "Creating application $projet on $username account"
    git remote add $project git@$server_ip:$project

    test -f Procfile || log "Now create at least a Procfile (for help, visit http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)"
    if is_python; then
        log "Then pip install your dependencies"
    elif is_node; then
        log "Then npm install your dependencies and write them in a package.json"
    elif is_ruby; then
        log "Then gem install your dependencies"
    fi
}


function deploy_dokku_app() {
    project=$1
    commit_comment=$2

    # Automatic dependencies detection, assuming a correct use of the virtualenv and pip
    if is_python; then
        if [[ $VIRTUAL_ENV == "" ]]; then
            log "Activating virtualenv for dependencies detection"
            source ./venv/bin/activate
        fi
        log "Storing app dependencies"
        pip freeze > requirements.txt
    fi

    # Updating git if necessary
    if [[ $(git status | grep "nothing to commit") == "" ]]; then
        log "Committing changes ($commit_comment)"
        git add -A
        git commit -m "$commit_comment"
    else 
        success "Nothing to commit, working directory clean" 
    fi

    log "Deploying to server application $project"
    git push $project master
    #TODO Attach
}


function run_in_container() {
    if [[ $# == 2 ]]; then
        log "Executing in container: $2"
        procfile="web: $2"
    else
        log "Reading Procfile to execute"
        procfile=`<Procfile`
    fi

    log "Not available yet"
}


#FIXME Does not work...
function repl_container() {
    container_name=$1
    interpreter=$2

    if [[ $interpreter == "ssh" ]]; then
        ssh_container $container_name
    else
        #FIXME Does not work
        docker_command="docker run -i -t app/$container_name $interpreter"
    fi
}


function ssh_container() {
    #TODO Save ssh key to avoid password stuff
    project=$1

    ssh_port=$(python -c "from docker_client import DockerClient; print DockerClient(host='$server_ip', port=$server_port).container('app/$PROJECT:latest').forwarded_ssh()")

    if [ $ssh_port ]; then
        log "Got SSH Port: $ssh_port, connecting..."
        ssh root@$server_ip -p $ssh_port
    fi
}
