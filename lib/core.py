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


#TODO Add help for set and get
#TODO Git stuff from bash to here
#TODO ssh as well, check juju sources they did it


from docker_client import DockerClient
import utils

import os
import redis
import sys
import time


class Pencil(DockerClient):

    def __init__(self, app=None, **kwargs):
        DockerClient.__init__(self, **kwargs)

        self._username = os.getlogin()

        # If app name was not provided, assuming it is directory name
        self.app = app or os.path.split(os.getcwd())[-1]
        is_tagged = self.app.find(':')
        if is_tagged != -1:
            # Tag was provided
            self.tag = self.app[(is_tagged + 1):]
            self.app = self.app[:is_tagged]
        else:
            # Default one
            self.tag = 'latest'

        #TODO Something more reliable (juju as a _cmd function in lib/lxc/__init__.py
        self._shell = os.system

        #TODO Not always connect to redis ?
        #NOTE db keyworld ?
        self.redis_client = redis.StrictRedis(
            host=kwargs.get('host', 'localhost'), port=6379, db=0)
        try:
            self.redis_client.echo('ping')
            utils.success('Connected to configuration server.')
        except redis.ConnectionError, e:
            utils.fail(e.message)

    def create_user(self):
        utils.log('Registering {} account'.format(self._username))
        result = self.redis_client.hset(
            self.app, 'username', self._username)
        utils.success('Got: {}'.format(result))

        self._shell('dokuant create-user {}'.format(self._username))
        utils.success('Done')

    def create_app(self):
        utils.log('Initializing dokku application...')
        self._shell('dokuant create-app {} {}'.format(
            self._username, self.app))
        utils.success('Done')

    def deploy(self, attach=False, comment='automatic'):
        self._shell('dokuant deploy {} {}'.format(self.app, comment))

        if attach:
            try:
                container = self.container(
                    '{}/{}:latest'.format(self._username, self.app))
                container.attach()
            except ValueError, e:
                utils.fail(e.message)

    def get(self, key):
        if key == 'images':
            self.list_images()
        elif key == 'apps':
            self.list_containers()
        #NOTE Kind of a conflic with get config
        elif key == 'status':
            try:
                container = self.container(
                    '{}/{}:latest'.format(self._username, self.app))
                container.inspect()
            except ValueError, e:
                utils.fail(e.message)
        else:
            utils.log('Requesting value of {} (namespace {})'.format(
                key, self.app))
            if key == 'config':
                result = self.redis_client.hgetall(self.app)
            else:
                result = self.redis_client.hget(
                    self.app, key)

            utils.success('{} = {}'.format(key, result))

    def set(self, key, value):
        utils.log('Setting config key "{}" to "{}" (namespace {})'.format(
            key, value, self.app))
        feedback = self.redis_client.hset(self.app, key, value)
        utils.success('Got: {}'.format(feedback))

    def connect(self, ip):
        # If needed, run or restart an ssh-ready requested image
        #FIXME No decr if container already running
        mapped_ssh_port = self.redis_client.decr('default_ssh_port')
        utils.log('Mapping ssh port to {}'.format(mapped_ssh_port))

        self.run('{}/{}:{}'.format(self._username, self.app, self.tag),
                 '/usr/sbin/sshd -D',
                 ports=['{}:22'.format(mapped_ssh_port)])

        # Depending on what did run function, ssh port could not be the
        # one we gave. So we fetch this information back
        real_ssh_port = self.container('{}/{}:{}'.format(
            self._username, self.app, self.tag)).forwarded_ssh()
        time.sleep(1)  # Wait for the container to boot I guess

        self._shell('ssh root@{} -p {}'.format(ip, real_ssh_port))

    def get_container(self):
        try:
            container = self.container(
                '{}/{}:{}'.format(self._username, self.app, self.tag))
        except ValueError, e:
            utils.fail(e.message)
            sys.exit(1)

        return container

    def snapshot(self, newname, newtag):
        container = self.get_container()
        newtag = newtag if newtag else pencil.tag

        container.commit(repository='{}/{}'.format(self._username, newname),
                         tag=newtag,
                         author=self._username)
        utils.success('Application committed to {}/{}:{}'.format(
            self._username, newname, newtag))
