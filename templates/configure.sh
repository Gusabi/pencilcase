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


# A hack try for generic use
#HOME=${HOME:="/home/vagrant"}
#echo "$HOME" # $> /root

LOGS="$HOME/dotfiles.log"
echo "Logs will be stored in $LOGS"


# Run a full apt-get update first.
echo "Updating apt-get caches..."
apt-get -y update 2>&1 >> "$LOGS"

if [[ "$HOME" == "/root" ]]; then
    packages_path="/vagrant"
else
    packages_path="."
fi
echo "Installing required packages"
if [ -f $packages_path/packages.txt ]; then
    xargs apt-get install -y --force-yes < $packages_path/packages.txt 2>&1 >> "$LOGS"
else
    apt-get install git vim curl openssh-client openssh-server libmysqlclient-dev mysql-client
fi
apt-get clean 2>&1 >> "$LOGS"

echo "Cloning dotfile repository"
# --recursive ships vim plugins with the rest
git clone --recursive https://github.com/Gusabi/Dotfiles.git $HOME/.dotfiles

echo "Configuring environment"
#$HOME/.dotfiles/bootstrap.sh 2>&1 "$LOGS"
$HOME/.dotfiles/bootstrap.sh
