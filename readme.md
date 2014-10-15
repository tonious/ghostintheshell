# Ghost In A Shell

This is a quick little demo that shows how to bring up the Ghost blogging
platform in a virtual machine, as provisioned using a shell script.

This script will automatically install Ghost, along with Varnish and
PostgreSQL.  It will create a user and database in PostgreSQL for Ghost (with
an overly simplistic password).  Additionally, it will set up Varnish to listen
on port 80, and make backend requests directly to Ghost (internally on port
2368).

This is a simple blog set up, but one that should be able to survive a
surprising amount of traffic.

## Running this demo:

### Using Vagrant

Using [Vagrant](http://vagrantup.com) and the virtualization engine of your
choice, you can see this in action:

~~~~~
twilek:ghostintheshell tony$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'trusty32'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: ghostintheshell_default_1413392869386_99456
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
...
==> default: ghost: started
twilek:ghostintheshell tony$ 
~~~~~

This might take a fair amount of bandwidth, as it will download an image of
Ubuntu 14.04 LTS if you do not have it handy already.

Once your vagrant box has booted and provisioned, you will be able to see Ghost
in action by navigating to [http://127.0.0.1:8080](http://127.0.0.1:8080).

### Using your own VM or hardware.  

Starting from a clean install of Ubuntu 14.04 LTS, check out or download a copy
of `provision.sh`.  Then, run it as root, either directly or via `sudo`.

~~~~~
root@li439-175:~# bash provision.sh 

## Populating apt-get cache...
...

Restarted supervisord
ghost: stopped
ghost: started
root@li439-175:~# 
~~~~~

By default, this will listen for web requests on port 80.

## Caveats.

Provisioning with a shell script is quick and easy, but it gets complicated
when updating running machines.  A dedicated configuration management tool like
Puppet, Chef or Ansible can verify the state of a machine and will only make
modifications when necessary.  Shell scripts tend to be less idempotent.
