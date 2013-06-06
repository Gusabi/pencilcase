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
    log "Usage: $0 command project -a author -s strategie"
}


IP="192.168.0.17"
AUTHOR=""
STRATEGIE=""
MANAGER=""
SOURCE=""
while getopts :hsma: OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             STRATEGIE=$OPTARG
             ;;
         a)
             AUTHOR=$OPTARG
             ;;
         m)
             MANAGER=$OPTARG
             ;;
         s)
             SOURCE=$OPTARG
             ;;
         i)
             IP=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done


PROJECT=$2
#TODO Much better check
if [ $# -lt 2 ]; then
    usage
    die "Insufficient number of args, exiting..."
fi


function link_strategie_files() {
    PROJECT=$1
    while IFS=' ' read -ra ADDR; do
        for file in "${ADDRE[@]}"; do
            # Detect
            if [[ $(cat $PROJECT/$file | grep "TradingAlgorithm") != "" ]]; then
                target_path="$QTRADE/neuronquant/algorithmic/strategies"
            elif [[ $(cat $PROJECT/$file | grep "PortfolioManager") != "" ]]; then
                target_path="$QTRADE/neuronquant/algorithmic/managers"
            elif [[ $(cat $PROJECT/$file | grep "DataSource") != "" ]]; then
                if [[ "$file" == *"Live"* ]]; then
                    target_path="$QTRADE/neuronquant/data/ziplinesources/live"
                else
                    target_path="$QTRADE/neuronquant/data/ziplinesources/backtest"
                fi
            fi

            #Link
            link_files $(pwd)/$PROJECT/$file $target_path/$file
        done
    done <<< "$(ls $PROJECT)"
}


function build_dir_tree() {
    # Create local directory
    log "Creating new project directory"
    mkdir $PROJECT
    log "Creating remote new project directory"
    ssh $USER@$IP "mkdir /home/$USER/quantlab/$PROJECT"
    success "Done"
}


function render_template_files() {
    log "Generating project files from templates"
    ./generate_env.py $PROJECT --author $AUTHOR \
        --strategie $1 --manager $2 --source $3
    success "Done"
}


function init_workspace() {
    log "Initiating worspace repository"
    cd $PROJECT
    git init
    git add -A
    git commit -m "Initial commit"

    #FIXME 
    #log "Setting up remote deployment"
    #mina setup -v
}


#TODO Multiple project: mina -f config/project_deploy.rb ?
function sync_workspace() {
    log "Pushing local work to remote repos"
    mina deploy -v
}


if ! is_installed "mina"; then
    log "Installing mina deployment tool"
    sudo gem install mina
else
    success "Mina gem already installed"
fi

if [ $1 == "setup" ]; then
    build_dir_tree
    render_template_files $STRATEGIE $MANAGER $SOURCE
    init_workspace
    #sync_workspace

elif [ $1 == "sync" ]; then
    sync_workspace

elif [ $1 == "link" ]; then
    link_strategie_files $PROJECT

fi

success "Done"

