percona-multi
=============

Chef wrapper cookbook to create Percona master/slave server setups. This wrapper
should work on all Debian and RHEL platform family OS's.

Utilization
------------

This cookbook works as a wrapper around the community Percona cookbook to allow
for the creation of master/slave and master/multi-slave Percona systems.

This cookbook utilizes two recipes depending on the server's defined role.

`master.rb` : sets up a master Percona server and creates replicant users for each
slave node defined within the attributes

`slave.rb` : sets up a slave Percona server pointing it to the master node defined
within attributes.

There is no search function within this cookbook. The IP addresses of the master
and slave nodes must be defined in attributes before it will converge.

Also keep in mind that passwords have to be set via encrypted data bags as outlined
in the [percona cookbook] (https://github.com/phlipper/chef-percona#encrypted-passwords)

Attributes
------------
Local attributes --

`['percona']['master']` : sets the IP address that defines the master node

`['percona']['slaves']` : is any array that defines the IP address(es) of
the slave node(s).

Percona cookbook attributes to be aware of --

`['percona']['server']['bind_to']` : should be set to "private_ip" vice default of
"public_ip" to ensure Percona is listening on the internal IP.

License & Authors
-----------------
- Author:: Christopher Coffey (<christopher.coffey@rackspace.com>)

```text

Copyright:: 2015 Rackspace US, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
