#
# Cookbook Name:: percona-multi
# Recipe:: slave
#
# Copyright 2015, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node.default['percona']['server']['bind_address'] = '0.0.0.0'

include_recipe 'apt' if platform_family?('debian')
include_recipe 'percona::server'
include_recipe 'percona::client'

mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Percona
  action :install
end

# creates unique serverid via ipaddress to an int
require 'ipaddr'
serverid = IPAddr.new node['ipaddress']
serverid = serverid.to_i

passwords = EncryptedPasswords.new(node, node['percona']['encrypted_data_bag'])

# drop MySQL slave specific configuration file
percona_config 'slave replication' do
  config_name 'slave'
  cookbook node['percona']['replication']['templates']['master.cnf']['cookbook']
  source node['percona']['replication']['templates']['master.cnf']['source']
  variables(
    cookbook_name: cookbook_name,
    serverid: serverid
  )
  notifies :restart, 'service[mysql]', :immediately
end

# slave sync provider
percona_slave_sync 'default' do
  replpasswd passwords.replication_password
  rootpasswd passwords.root_password
  master_ip node['percona']['master']
end

tag('percona_slave')
