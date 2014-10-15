#!/bin/bash

# Install some prerequisites.
curl -sL https://deb.nodesource.com/setup | sudo bash -
apt-get install -y nodejs build-essential unzip supervisor postgresql postgresql-client libpq-dev varnish

# Set up our database.
cat <<EOF | su postgres -c psql
CREATE USER ghost WITH PASSWORD 'password';
CREATE DATABASE ghost OWNER ghost;
GRANT ALL PRIVILEGES ON DATABASE ghost TO ghost;
EOF

# Now let's do varnish.
cat <<EOF > /etc/varnish/default.vcl
backend default {
    .host = "127.0.0.1";
    .port = "2368";
}
EOF

cat <<EOF > /etc/default/varnish
# Should we start varnishd at boot?  Set to "no" to disable.
START=yes

# Maximum number of open files (for ulimit -n)
NFILES=131072

# Maximum locked memory size (for ulimit -l)
MEMLOCK=82000

DAEMON_OPTS="-a :80 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s malloc,256m"
EOF

/etc/init.d/varnish restart

# Install Ghost and it's dependancies.
wget https://ghost.org/zip/ghost-0.5.2.zip -o /dev/null -O /tmp/ghost-0.5.2.zip
mkdir -p /var/www/ghost
cd /var/www/ghost
unzip /tmp/ghost-0.5.2.zip
npm install --production
npm install pg

# Configure Ghost
cat <<EOF > /var/www/ghost/config.js
// # Ghost Configuration
// Setup your Ghost install for various environments
// Documentation can be found at http://support.ghost.org/config/

var path = require('path'),
    config;

config = {
    // ### Production
    // When running Ghost in the wild, use the production environment
    // Configure your URL and mail settings here
    production: {
        url: 'http://localhost:2368',
        mail: {},
        database: {
            client: 'pg',
            connection: {
                host     : '127.0.0.1',
                user     : 'ghost',
                password : 'password',
                database : 'ghost',
                charset  : 'utf8'
            },
            debug: false
        },

        server: {
            // Host to be passed to node's net.Server#listen()
            host: '0.0.0.0',
            // Port to be passed to node's net.Server#listen(), for iisnode set this to process.env.PORT
            port: '2368'
        }
    }
};

// Export config
module.exports = config;
EOF

# Configure supervisorctl
cat <<EOF > /etc/supervisor/conf.d/ghost.conf
[program:ghost]
command = node /var/www/ghost/index.js
directory = /var/www/ghost
environment = NODE_ENV="production"
EOF

supervisorctl reload
supervisorctl restart ghost
