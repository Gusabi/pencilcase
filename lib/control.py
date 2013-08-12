#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2013 xavier <xavier@laptop-300E5A>
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


from utils import fail, success
from core import Pencil

import sys
import os


def main(args):
    '''
    Main entry for final user
    Use arguments parsed by docopt
    '''
    try:
        server_ip = os.environ['SERVERDEV_IP']
        docker_port = os.environ['SERVERDEV_PORT']
    except KeyError, e:
        fail(e.message)
        sys.exit(1)

    pencil = Pencil(app=args['--app'], host=server_ip, port=docker_port)

    if args['create']:
        if args['user']:
            pencil.create_user()

        if args['app']:
            pencil.create_app()

    elif args['deploy']:
        pencil.deploy()

    elif args['get']:
        pencil.get(args['<key>'])

    elif args['set']:
        pencil.set(args['<key>'], args['<value>'])

    elif args['connect']:
        pencil.connect(server_ip)

    # Here we go for docker stuff
    else:
        container = pencil.get_container()
        #TODO execute
        #TODO push
        #TODO restart, does not work for now
        if args['start']:
            container.start(attach=args['--attach'])
            success('Application started.')

        elif args['kill']:
            container.kill()
            success('Application killed.')

        elif args['stop']:
            container.stop()
            success('Application stopped.')

        elif args['remove']:
            container.remove()
            success('Application destroyed.')

        elif args['attach']:
            container.attach()

        elif args['log']:
            container.logs(display=True)

        elif args['snapshot']:
            pencil.snapshot(args['--name'], args['--tag'])
