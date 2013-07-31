#!/bin/bash
#NOTE With QUANTRADE_REPO set before installation this script could be generic

set -e
export DEBIAN_FRONTEND=noninteractive
export QUANTLAB_REPO=${QUANTLAB_REPO:-"https://github.com/Gusabi/quantlab.git"}

#TODO project=https://.../[].git

# A hack try for generic use, especially vagrant and docker compliant
if [[ "$HOME" == "/root" ]]; then
    ## We are in a vagrant box, at bootstrap
    export HOME="/home/vagrant"
    export USER="vagrant"
elif [[ "$HOME" == "/" ]]; then
    # We are in a docker (lxc ?) container
    export HOME="/root"
    export USER=$(whoami)
fi

LOGS="/tmp/quantlab.log"
echo "[bootstrap] Logs stored in $LOGS"

# Run a full apt-get update first.
echo "[bootstrap] Updating apt-get caches..."
apt-get update 2>&1 >> "$LOGS"

# Install required packages
echo "[bootstrap] Installing git and make..."
apt-get -y --force-yes install git make 2>&1 >> "$LOGS"

cd $HOME 
# The test makes it vagrant compliant (synced folders)
test -d quantlab || git clone $QUANTLAB_REPO
cd quantlab
make all

echo "[bootstrap] Done."
