#!/usr/bin/env node
'use strict';

//TODO server_ip as local detection

// Rest lib: http://mcavage.github.io/node-restify/
// Logging: https://github.com/trentm/node-bunyan
var program = require('commander'),
    log = require('logging'),
    mysql = require('mysql'),
    restify = require('restify'),
    mu = require('mu2'),
    fs = require('fs'),
    spawn = require('child_process').spawn;

program
  .version('0.0.1')
  .usage('[command] <args>')
  .description('RESTFul server')
  .option('-s, --server <adress>', 'mysql database adress', String, 'localhost')
  .option('-p, --password <chut>', 'mysql password', String, '')
  .parse(process.argv);


function get_local_ip() {
    varos = require('os');
    var networkInterfaces = os.networkInterfaces();

    // Prefere ethernet over wifi
    if ('eth0' in network ) 
        interface_name = 'eth0'
    else if ('wlan0' in network ) 
        interface_name = 'wlan0'

    return network[interface_name][0]['address']
}


function fireup_env(configuration, filename, build_env_callback) {
    //mu.root = __dirname + '/templates';
    mu.root = process.env.HOME + '/local/templates'
    var buffer = '';

    mu.compileAndRender(filename, configuration)
        .on('data', function (c) { buffer += c.toString(); })

        .on('end', function () {
            fs.writeFile('Vagrantfile', buffer.toString(), function (err) {
                if (err) 
                    return log(err);
                log ('Dev::renderer::operation is completed')

                build_env_callback();
        });
    });
}


function finalize(file_path, response_callback) {
    fs.readFile(file_path, 'utf8', function (err, data) {
        if (err) {
            return log(err);
        }

        response_callback(data);
    });
}


function box_management(req, res, next) {
    log('Box::Received request with params ', req.params)
    log('Box::Running on project ', req.params.project, ': ', req.params.command)

    // run vagrant $command
    //TODO commands that need interaction (vagrant destroy) fail
    log('Dev::Cloning repos ' + req.params.project + ' of ' + req.params.ghuser)
    var child = spawn('manage_box.sh', ['run', req.params.command, req.params.project]);

    child.stdout.on('data', function (data) {
        //NOTE verbose condition ?
        log('Dev::vm_starter:stdout::' + data);
    });

    child.stderr.on('data', function (data) {
        log('Dev::vm_starter::stderr::' + data);
    });

    child.on('exit', function (code, signal) {
        if (code == 0) {
            log('Dev::vm_starter::Successful');
        }
        else {
            log('** Dev::vm_starter::Error');
            return undefined;
        }
        child.stdin.end()
        child = undefined;
    })
    log('Spawned process (' + child.pid + ')')

    log('Sending back ackowledgment')
    //TODO We don't see local log from remote
    res.send({'status': 'done'});
    
    return next();
}


function dev_env(req, res, next) {
    // Request: http://127.0.0.1:8080/dev/quantrade?image=quantal64\&memory=1024
    //TODO Default values
    log('Dev::Received request with params ', req.params);
    log('Dev::Working on project ', req.params.project);

    var image_uris = {
        //TODO provider specific dictionaries
        //'quantal64': 'http://dl.dropbox.com/u/13510779/lxc-quantal-amd64-2013-05-08.box',
        'precise64': 'http://files.vagrantup.com/precise64.box'
    };

    var box_configuration = {
        box_name: req.params.image,
        box_uri: image_uris[req.params.image],
        username: req.params.user,
        memory: req.params.memory
    };

    fireup_env(box_configuration, 'vagrant_vb.tpl', function() {
        // run vagrant up
        log('Dev::Cloning repos ' + req.params.project + ' of ' + req.params.ghuser)
        var child = spawn('manage_box.sh', ['create', req.params.ghuser, req.params.project]);

        child.stdout.on('data', function (data) {
            //NOTE verbose condition ?
            log('Dev::vm_starter:stdout::' + data);
        });

        child.stderr.on('data', function (data) {
            log('Dev::vm_starter::stderr::' + data);
        });

        child.on('exit', function (code, signal) {
            if (code == 0) {
                log('Dev::vm_starter::Successful');
            }
            else {
                log('** Dev::vm_starter::Error');
                return undefined;
            }
            child.stdin.end()
            child = undefined;
        })
        log('Spawned process (' + child.pid + ')')

        finalize('/home/xavier/.vagrant.d/insecure_private_key', function (ssh_key) {
            log('Sending back connection informations')
            res.send(
                {'ip': get_local_ip(),
                 'port': 2222,
                 'key': ssh_key
            })
        })

        return 0;
    });

    log('Request processed')
    return next();
};


var server = restify.createServer({name: 'R&D test'});

server.use(restify.acceptParser(server.acceptable));
server.use(restify.authorizationParser());
server.use(restify.dateParser());
server.use(restify.queryParser());
server.use(restify.bodyParser());
server.use(restify.throttle({
    burst: 100,
    rate: 50,
    ip: true, // throttle based on source ip address
    overrides: {
        get_local_ip(): {
            rate: 0, // unlimited
    burst: 0
        }
    }
}));


server.get('/dev/:project', dev_env);
server.get('/box/:project', box_management);

var port = 8080;
var ip = get_local_ip();
server.listen(port, ip, function() {
    log(server.name + ' listening at ' + server.url);
});


process.on('SIGINT', function() {
    log('Got SIGINT signal, exiting...');
    process.exit(0);
});


process.on('exit', function() {
    //connection.end();
    log('Shutting down REST server');
});

process.on('uncaughtException', function(err) {
    log('warning: Uncaught error occured')
})
