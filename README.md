percona-multi
=============

Chef wrapper cookbook to create Percona master/slave server setups. This wrapper
should work on all Debian and RHEL platform family OS's.

Utilization
------------

This cookbook works as a wrapper around the community Percona cookbook to allow
for the creation of master/slave and master/multi-slave Percona systems.

The current version of this cookbook has gone to a pure libraries format, the recipes
listed below have been left for backwards compatibility as well as for guides in
writing your own.

The two recipes depending on the server's defined role:

`master.rb` : sets up a master Percona server and creates replicant users for each
slave node defined within the attributes

`slave.rb` : sets up a slave Percona server pointing it to the master node defined
within attributes.

Keep in mind that passwords have to be set via encrypted data bags as outlined
in the [percona cookbook] (https://github.com/phlipper/chef-percona#encrypted-passwords)

There is no search function within this cookbook. The IP addresses for the servers
has to be set as attributes and build order becomes important.Your orchestration
layer should build the servers, then the IP addresses should be set as attributes,
then the master node should then be converged prior to converging the slave nodes.

MySQL2 Gem
------------
The libraries provided in this cookbook require the use of the MySQL2 gem provider
which is part of the percona cookbook it should be called directly like the below
example:

```ruby

mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Percona
  action :install
end

```

Also ensure you have depends statements for both 'percona' and 'mysql2_chef_gem'
in your metadata.rb file.

Attributes
------------
Local attributes --

`['percona']['master']` : sets the IP address that defines the master node

`['percona']['slaves']` : is any array that defines the IP address(es) of
the slave node(s).


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
