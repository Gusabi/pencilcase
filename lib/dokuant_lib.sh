#! /bin/bash
#
# dokuant_lib.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


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
    cat ~/.ssh/id_rsa.pub | ssh root@$HOSTNAME "gitreceive upload-key $1"
}


function create_dokku_app() {
    #NOTE Python by heroku: https://devcenter.heroku.com/articles/python
    log "Initializing Dokku application"

    log "Setting up git workspace"
    git init
    git add -A
    git commit -m "Initial commit"

    if is_python; then
        log "Python app detected"
        log "Creating virtual environment"
        virtualenv venv --distribute --no-site-packages
        #FIXME Activates nothing
        source venv/bin/activate
        echo "venv" >> .gitignore
        echo "*.pyc" >> .gitignore
        #NOTE Parse *.py files and pip install them ? then pip freeze, etc...
    fi

    #TODO Automatic creation when first deployment ?
    log "Creating application $2 on $1 account"
    git remote add $2 git@$HOSTNAME:$2

    log "Now create at least a Procfile (for help, visit http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)"
    if is_python; then
        log "Then pip install your dependencies"
    elif is_ruby; then
        log "Then gem install your dependencies"
    fi
}


function deploy_dokku_app() {
    if is_python; then
        if [[ $VIRTUAL_ENV == "" ]]; then
            log "Activating virtualenv for dependencies detection"
            source ./venv/bin/activate
        fi
        log "Storing app dependencies"
        pip freeze > requirements.txt
    fi

    if [[ $(git status | grep "nothing to commit") == "" ]]; then
        log "Committing changes"
        git add -A
        git commit -m 'Automatic commit'
    else
        success "Nothing to commit, working directory clean"
    fi

    log "Deploying to server"
    git push $1 master
}


function run_in_container() {
    procfile=`<Procfile`
    docker_command="docker run app/$1 /bin/bash -c \"echo '$procfile' > /app/Procfile && /start web\""
    echo $docker_command
    #remote_execution $docker_command
    ssh -n -l $USER $HOSTNAME "$docker_command"
}


function remote_execution() {
    ssh_command=$1
    log "Executing remotely: $ssh_command"
    log

    ssh -n -l $USER $HOSTNAME "$ssh_command"
    log
}


function get_container_id() {
    echo "\`cat /home/git/$1/CONTAINER\`"
}


function fetch_container_info() {
    #TODO Json processing of the anwser
    remote_execution "docker inspect $(get_container_id $1)"
}
