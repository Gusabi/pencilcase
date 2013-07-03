#! /usr/bin/env python
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


import sys

from neuronquant.gears.engine import Simulation
from neuronquant.utils.logger import log, get_nestedlog
from neuronquant.gears.configuration import Setup


if __name__ == '__main__':
    # Dedicated object for configuration setup
    setup = Setup()

    # General simulation behavior is defined using command line arguments
    configuration = setup.parse_commandline()

    # Color_setup : Pretty print of errors, warning, and so on
    # Remote_setup: ZMQ based messaging, route logs on the network
    # (catched by server's broker)
    #TODO Parametric log handler and level
    #log_setup = (utils.remote_setup if configuration['remote'] else
                 #utils.color_setup)

    #FIXME Remote log broken here
    log_setup = get_nestedlog(level=configuration['loglevel'],
                              filename=configuration['logfile'])
    with log_setup.applicationbound():
        '''
        TODO HUGE: Run multiple backtest with communication possibilities (ZMQ)
             for sophisticated multiple strategies strategy
                 - Available capital allocation
                 - Strategies repartition
                 - Use of each-other signals behavior
                 - Global monitoring and evaluation
        '''

        # Fill strategie and manager parameters
        # Localy, reading configuration file
        # Remotely, listening gor messages through zmq socket
        strategie = setup.get_strategie_configuration(
            remote=configuration['remote'])

        # Backtest or live engine
        engine = Simulation(configuration)

        # Setup quotes data and financial context (location, market, ...)
        # simulation from user parameters Wrap _configure_data() and
        # _configure_context() you can use directly for better understanding
        data, trading_context = engine.configure()

        # See neuronquant/gears/engine.py for details of results
        #which is an Analyzes object
        analyzes = engine.run(data, configuration, strategie, trading_context)

        if analyzes is None:
            log.error('** Backtest failed.')
            sys.exit(1)

        log.info('Portfolio returns: \
                {}'.format(analyzes.results.portfolio_value[-1]))
