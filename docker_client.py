#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2013 xavier <xavier@laptop-300E5A>
#
# Distributed under terms of the MIT license.


import docker
import logbook
log = logbook.Logger('Docker::client')


class DockerClient(object):

    def __init__(self, host='localhost', port='4243', version='1.3'):
        #TODO Implement a test to check if it worked
        self._client = docker.Client(
            base_url='http://{}:{}'.format(host, port), version=version)
        self.info = self._client.info()
        self.info.update(self._client.version())
        if self.info:
            log.info('Connected to Docker server (version {})'.format(
                self.info['Version']))
        else:
            log.error('Unable to connect to docker server ({}:{})'.format(
                host, port))

    def get_container_id(self, name, is_running=False, command=None):
        #TODO Dates stuff
        containers = self._client.containers(all=(not is_running))
        # Filter by name, then by command, and finally keep the latest
        #NOTE Automatically add ':latest' ?
        candidates = filter(lambda box: box['Image'] == name, containers)
        log.debug('Found {} containers named {}'.format(len(candidates), name))

        if command and candidates:
            candidates = filter(lambda box: box['Command'] == command, candidates)
            log.debug('Found {} containers running {}'.format(len(candidates), command))

        if not candidates:
            log.warning('! No container found ({}, {})'.format(name, command))
            return None

        return sorted(candidates, key=lambda box: box['Created'])[-1]['Id']

    def get_ssh_mapping(self, container_name):
        id = self.get_container_id(container_name, is_running=True)
        if id:
            return self._client.port(id, 22)
        return None
