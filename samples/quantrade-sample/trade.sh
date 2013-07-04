#! /bin/bash
#
# run.sh
# Copyright (C) 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.
#


while true; do
    echo "Fetching connection informations"
    scp -i ./id_rsa xavier@192.168.0.17:dev/ipcontroller-engine.json .

    echo "Running drone..."
    ipengine --file=ipcontroller-engine.json
done
