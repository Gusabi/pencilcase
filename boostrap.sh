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


log "    Dokuan & Shaker    "
log "_______________________"
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
