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


'''Quantlab.

Usage:
  generate_env.py <project> --author=<name> --strategie=<name> [--manager=<name>] [--source=<name>] [--year=<xxxx>]
  generate_env.py (-h | --help)
  generate_env.py --version

Options:
  -h --help           Show this screen.
  --version           Show version.
  --author=<name>     Author of the algorithm
  --strategie=<name>  Strategie name
  --source=<name>     Data source name
  --manager=<name>    Manager name
  --year=<xxxx>       Current year for copyright [default: 2013].

'''


from docopt import docopt
import socket
from urllib2 import urlopen
import re
import os
import jinja2
import logbook
log = logbook.Logger('Generator')


def get_ip(public=False):
    if public:
        data = str(urlopen('http://checkip.dyndns.com/').read())
        return re.compile(r'Address: (\d+\.\d+\.\d+\.\d+)').search(data).group(1)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('google.com', 0))
    return s.getsockname()[0]


def generate_from_template(completion, tpl_file, out_file=None):
    templates_path = './templates'

    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(templates_path))
    template = env.get_template(tpl_file)
    log.info('Rendering template')
    document = template.render(completion)

    if out_file:
        log.info('Writing tempalte to {}'.format(out_file))
        with open(out_file, 'w') as fd:
            fd.write(document.encode('utf8'))


if __name__ == '__main__':
    arguments = docopt(__doc__, version='New algorithm environment generator')

    completion = {'author': arguments['--author'],
                  'strategie': arguments['--strategie'],
                  'manager': arguments['--manager'],
                  'source': arguments['--source'],
                  'deploy': arguments['<project>'],
                  'user': os.environ['USER'],
                  'ip': get_ip(),
                  'remote_ip': '192.168.0.17',
                  'year': arguments['--year']}

    for plugin in ['strategie', 'manager', 'source', 'deploy']:

        if plugin == 'deploy':
            target_path = 'config/' + plugin + '.rb'
        else:
            target_path = arguments['<project>'] + '/' + plugin + '.py'

        if completion[plugin]:
            generate_from_template(completion,
                                   '.'.join((plugin, 'tpl')),
                                   target_path)
