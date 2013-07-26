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
if [[ "$HOME" == "/root" ]]; then
    # We are in a vagrant box
    packages_path="/vagrant"
elif [[ "$HOME" == "/" ]]; then
    # We are in a docker (lxc ?) container
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

log "Cloning dotfile repository..."
# --recursive ships vim plugins with the rest
git clone --recursive https://github.com/Gusabi/Dotfiles.git $HOME/.dotfiles 2>&1 >> "$LOGS"

success "Done, bootstraping environment..."
#FIXME No arguments... Ask question and detect non-interactivity ? ENV var ?
GUSER=${GIT_USER:-"robot"}
GMAIL=${GIT_MAIL:-"robot@example.com"}
shell=${shell:-"bash"}
NODE_VERSION=${NODE_VERSION:-"0.10.12"}
PLUGINS=${PLUGINS:-""}

#$HOME/.dotfiles/bootstrap.sh 2>&1 "$LOGS"
$HOME/.dotfiles/bootstrap.sh -u $GUSER -m $GMAIL -n $NODE_VERSION -s $shell -p $PLUGINS
