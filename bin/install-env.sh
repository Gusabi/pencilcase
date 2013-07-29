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


function log () {
  printf "\r\033[00;36m  [ \033[00;34m..\033[00;36m ] $1\033[0m\n"
}


success () {
  printf "\r\033[00;36m  [ \033[00;32mOK\033[00;36m ] $1\033[0m\n"
}


LOGS="dotfiles.log"
log "Logs will be stored in $PWD/$LOGS"


# Run a full apt-get update first.
log "Updating apt-get caches..."
apt-get -y update 2>&1 >> "$LOGS"


log "Installing required packages"
apt-get -y --force-yes install git vim curl openssh-client openssh-server libmysqlclient-dev mysql-client 2>&1 >> "$LOGS"

#TODO Better env detection ?
if [[ "$HOME" == "/root" ]]; then
    # We are in a vagrant box
    packages_path="/vagrant"
elif [[ "$HOME" == "/" ]]; then
    # We are in a docker (lxc ?) container
    #NOTE Am I sure it's in /app ? maybe in build ?
    packages_path="/app"
    export HOME="/root"
else
    packages_path="."
fi

if [ -f $packages_path/packages.txt ]; then
    log "Found extra package list, installing them"
    xargs apt-get install -y --force-yes < $packages_path/packages.txt 2>&1 >> "$LOGS"
fi
success "Done, cleaning..."
apt-get clean 2>&1 >> "$LOGS"

#TODO json or yaml format + other configs: apt, pip, ...
if [ -f $packages_path/dev.env ]; then
    log "Reading configuration"
    . dev.env
fi

GIT_USER=${GIT_USER:-"enoch"}
GIT_MAIL=${GIT_MAIL:-"enoch@example.com"}
shell=${shell:-"bash"}
NODE=${NODE:-"0.10.12"}
PLUGINS=${PLUGINS:-""}

log "Git user: $GIT_USER"
log "Git mail: $GIT_MAIL"
log "Shell: $shell"
log "Node version: $NODE"
log "Plugins: $PLUGINS"

log "Cloning dotfile repository..."
# --recursive ships vim plugins and gitignore with the rest
git clone --recursive https://github.com/Gusabi/Dotfiles.git $HOME/.dotfiles 2>&1 >> "$LOGS"

success "Done, bootstraping environment..."
$HOME/.dotfiles/bootstrap.sh -u $GUSER -m $GMAIL -n $NODE -s $shell -p $PLUGINS
