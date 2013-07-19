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


set -e
clear


source lib/utils.sh


log "    Dokuan & Shaker    "
log "_______________________"
log ""


function install_files() {
    SHELL_CONFIG_FILE=$1
    if [ ! -d $HOME/local/bin ]; then
        log "Creating ~/local/bin directory"
        mkdir -p $HOME/local/bin
        chown $USER $HOME/local/bin
        echo "export PATH=\$PATH:$HOME/local/bin" >> $SHELL_CONFIG_FILE
    fi
    log "Copying dokuant scripts to local bin"
    cp ./bin/* $HOME/local/bin
    chmod +x $HOME/local/bin/*
    chown $USER $HOME/local/bin/*

    if [ ! -d $HOME/local/lib ]; then
        log "Creating ~/local/lib directory"
        mkdir -p $HOME/local/lib
        chown $USER $HOME/local/lib
        echo "export PATH=\$PATH:$HOME/local/lib" >> $SHELL_CONFIG_FILE
    fi
    log "Moving dokuant lib to local lib"
    cp ./lib/* $HOME/local/lib
    #FIXME Does not work
    chown $USER $HOME/local/lib/*

    if [ ! -d $HOME/local/templates ]; then
        log "Creating ~/local/templates directory"
        mkdir -p $HOME/local/templates
        chown $USER $HOME/local/templates
    fi
    log "Copying dokuant templates to local templates"
    cp ./templates/* $HOME/local/templates
    chown $USER $HOME/local/templates/*

    log "Setting environment variable"
    echo "export SERVERDEV_IP=$2" >> $SHELL_CONFIG_FILE
    echo "export SERVERDEPLOY_IP=$3" >> $SHELL_CONFIG_FILE
    echo "export SERVERDEV_PORT=8080" >> $SHELL_CONFIG_FILE
}


function install_dependencies() {
    #FIXME httpie would not work on ubuntu 12.04
    #FIXME jq in bin is 64 bits dependant, detect and wget the stuff
    packages=""
    if ! is_installed "git"; then
        packages+=" git"
    else
        success "Git already installed"
    fi
    if ! is_installed "python-pip"; then
        packages+=" python-pip"
    else
        success "Pip already installed"
    fi

    if [[ $packages != "" ]]; then
        log "Installing packages $packages"
        sudo apt-get install $packages
        log "[Git configuration] Type your email adress, followed by enter: "
        read user_email
        git config --global user.email $user_email
        log "[Git configuration] Type your user name, followed by enter: "
        read user_name
        git config --global user.name $user_name
    fi

    pip install -r requirements.txt
}



# At least install_dependencies needs root permission for now
if [ $(whoami) != 'root' ]; then
    die "** Error: This installation script needs root permissions"
fi


#TODO help
while getopts ":d:e:" optname
do
  case "$optname" in
    "d")
        SERVERDEPLOY_IP=$OPTARG
        ;;
    "e")
        SERVERENV_IP=$OPTARG
        ;;
    "?")
        echo "Unknown option $OPTARG"
        ;;
    ":")
        echo "No argument value for option $OPTARG"
        ;;
    *)
        # Should not occur
        echo "Unknown error while processing options"
        ;;
  esac
done


if [[ $SHELL == "/bin/bash" ]]; then 
    log "Bash detected"
    SHELL_CONFIG_FILE="$HOME/.bashrc"

elif [[ $SHELL == "/bin/zsh" ]]; then 
    log "Zsh detected"
    SHELL_CONFIG_FILE="$HOME/.zshrc"

else
    fail "Unable to detect shell, assuming bash"
    SHELL_CONFIG_FILE="$HOME/.bashrc"
fi


# Default values
SERVERENV_IP=${SERVERENV_IP:-192.168.0.17}
SERVERDEPLOY_IP=${SERVERDEPLOY_IP:-192.168.0.17}

install_files $SHELL_CONFIG_FILE $SERVERENV_IP $SERVERDEPLOY_IP
install_dependencies
log "Done, repopen a terminal to make changes effective"
success "Dokuant ready to use, Yay !"

#NOTE Root execution might causes permission issue for copied files
#FIXME install_dependencies needs sudo permission (should be fixed/ok)
#FIXME Generate_quant_env is not executable after installation (should be fixed)
#FIXME If git has never been used, git config will stop execution (should be fixed)
#FIXME Install virtualenv (should be fixed)
#FIXME Every ssh command requires to be xavier (VM would solve this)
#FIXME User creation: automatic key generation if needed
#TODO Remplacer logbook par logging pour réduire les dépendances
