#! /bin/bash
#
# boostrap.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


set -e
clear

source lib/utils.sh

log "    Dokuan    "
log "______________"
log ""


function install_files() {
    SHELL_CONFIG_FILE=$1
    if [ ! -d $HOME/local/bin ]; then
        log "Creating ~/local/bin directory"
        mkdir -p $HOME/local/bin
        echo "export PATH=\$PATH:$HOME/local/bin" >> $SHELL_CONFIG_FILE
    fi
    log "Copying dokuant scripts to local bin"
    cp ./bin/* $HOME/local/bin

    if [ ! -d $HOME/local/lib ]; then
        log "Creating ~/local/lib directory"
        mkdir -p $HOME/local/lib
        echo "export PATH=\$PATH:$HOME/local/lib" >> $SHELL_CONFIG_FILE
    fi
    log "Moving dokuant lib to local lib"
    cp ./lib/* $HOME/local/lib

    if [ ! -d $HOME/local/templates ]; then
        log "Creating ~/local/templates directory"
        mkdir -p $HOME/local/templates
    fi
    log "Copying dokuant templates to local templates"
    cp ./templates/* $HOME/local/templates
}


function install_dependencies() {
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
    fi

    pip install -r requirements.txt
}



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
echo "" >> $SHELL_CONFIG_FILE
echo "# QuantLab configuration" >> $SHELL_CONFIG_FILE


install_files $SHELL_CONFIG_FILE
install_dependencies
log "Done"
success "Dokuant ready to use, Yay !"
