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


server_ip=${SERVERDEPLOY_IP:-192.168.0.17}
server_port=${SERVERDEPLOY_PORT:-4242}
#NOTE standard unix env variables forced temporary


function get_project_name() {
    pwd | awk -F"/" '{print $NF}'
}


function render_template_files() {
    log "Setting up quant environment"
    if [ $1 ]; then
        arguments+=" --strategie $1"
    fi
    if [ $2 ]; then
        arguments+=" --manager $2"
    fi
    if [ $3 ]; then
        arguments+=" --source $3"
    fi
    if [ $4 ]; then
        arguments+=" --author $4"
    fi
    log "Generating project files from templates"
    echo $arguments
    generate_quant_env.py $arguments
    success "Done"
}


function create_dokku_user() {
    #TODO generate id_rsa.pub
    #FIXME root password needed !!
    log "Creating $1 account"
    cat ~/.ssh/id_rsa.pub | ssh root@$server_ip "gitreceive upload-key $1"
}


function create_dokku_app() {
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
    log "Creating application $2 on $1 account"
    git remote add $2 git@$server_ip:$2

    log "Now create at least a Procfile (for help, visit http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)"
    if is_python; then
        log "Then pip install your dependencies"
    elif is_ruby; then
        log "Then gem install your dependencies"
    fi
}


function deploy_dokku_app() {
    project=$1
    commit_comment=$2
    if is_python; then
        if [[ $VIRTUAL_ENV == "" ]]; then
            log "Activating virtualenv for dependencies detection"
            source ./venv/bin/activate
        fi
        #FIXME Since unexpected github dependecies appear, disable for now automatic save
        #log "Storing app dependencies"
        #pip freeze > requirements.txt
    fi

    if [[ $(git status | grep "nothing to commit") == "" ]]; then
        log "Committing changes ($commit_comment)"
        git add -A
        git commit -m "$commit_comment"
    else
        success "Nothing to commit, working directory clean"
    fi

    log "Deploying to server application $project"
    git push $project master

    #TODO Use python script to fech and store informations
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

    ssh_port=$(python -c "from docker_client import DockerClient; print DockerClient(host='$server_ip', port=$server_port).get_ssh_mapping('app/$project:latest')")
    log "Asking server for SSH Port: $ssh_port"

    if [ $ssh_port ]; then
        log "Connecting to the box"
        ssh root@$server_ip -p $ssh_port
    fi
}
