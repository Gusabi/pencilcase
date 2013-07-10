#!/usr/bin/env node
'use strict';

// Rest lib: http://mcavage.github.io/node-restify/
// Logging: https://github.com/trentm/node-bunyan
var program = require('commander'),
    log = require('logging'),
    mysql = require('mysql'),
    restify = require('restify'),
    mu = require('mu2'),
    fs = require('fs'),
    spawn = require('child_process').spawn,
    config = require('config');

program
  .version('0.0.1')
  .usage('[command] <args>')
  .description('RESTFul server')
  .option('-s, --server <adress>', 'mysql database adress', String, 'localhost')
  .option('-p, --password <chut>', 'mysql password', String, '')
  .parse(process.argv);


function fireup_env(configuration, filename, build_env_callback) {
    //mu.root = __dirname + '/templates';
    mu.root = process.env.HOME + '/local/templates'
    var buffer = '';

    mu.compileAndRender(filename, configuration)
        .on('data', function (c) { buffer += c.toString(); })

        .on('end', function () {
            fs.writeFile('Vagrantfile', buffer.toString(), function (err) {
                if (err) 
                    return console.log(err);
                console.log(buffer.toString());
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
        //var git_repos = 'https://github.com/Gusabi/' + req.params.project
        log('Dev::Cloning repos ' + req.params.project + ' of ' + 'Gusabi')
        var child = spawn('go_box.sh', ['Gusabi', req.params.project]);

        child.stdout.on('data', function (data) {
            //NOTE verbose condition ?
            console.log('Dev::vm_starter:stdout::' + data);
        });

        child.stderr.on('data', function (data) {
            console.log('Dev::vm_starter::stderr::' + data);
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
            console.log(ssh_key);
            res.send(
                {'ip': '192.168.0.12',
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
        '192.168.0.12': {
            rate: 0, // unlimited
    burst: 0
        }
    }
}));


server.get('/dev/:project', dev_env);

var port = 8080;
var ip = '192.168.0.12';
server.listen(port, ip, function() {
    log(server.name + ' listening at ' + server.url);
});


process.on('SIGINT', function() {
    log('Got SIGINT signal, exiting...');
    process.exit(0);
});


process.on('exit', function() {
    //connection.end();
    log('Shutting down database and REST server');
});

process.on('uncaughtException', function(err) {
    log('warning: Uncaught error occured')
})
