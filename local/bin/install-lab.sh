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


export SERVERDEV_IP=${SERVERDEV_IP:-"192.168.0.17"}
export INSTALL_PATH=${INSTALL_PATH:-"/tmp"}

log "Development server: $SERVERDEV_IP"

log "Cloning lab repository in $INSTALL_PATH ..."
git clone https://github.com/Gusabi/quantlab.git $INSTALL_PATH/quantlab

success "Done, bootstraping environment..."
cd $INSTALL_PATH/quantlab
./bootstrap.sh -d $SERVERDEV_IP
