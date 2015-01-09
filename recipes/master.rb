#
# Cookbook Name:: percona-multi
# Recipe:: master
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

node.default['percona']['server']['role'] = ['master']

include_recipe 'chef-sugar'
include_recipe 'percona::server'

# creates unique serverid via ipaddress to an int
require 'ipaddr'
serverid = IPAddr.new node['ipaddress']
serverid = serverid.to_i

passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

# drop master specific configuration file
template "#{node['percona']['server']['includedir']}master.cnf" do
  cookbook node['percona']['replication']['templates']['master.cnf']['cookbook']
  source node['percona']['replication']['templates']['master.cnf']['source']
  variables(
  cookbook_name: cookbook_name,
  serverid: serverid
  )
  notifies :restart, 'service[mysql]', :immediately
end
execute 'grant-slave' do
  command <<-EOH
  /usr/bin/mysql -u root -p'#{passwords.root_password}' < /root/grant-slaves.sql
  rm -f /root/grant-slaves.sql
  EOH
  action :nothing
end

# Grant replication user and control to slave(s)
node['percona']['slaves'].each do |slave|
  template "/root/grant-slaves.sql #{slave}" do
    path '/root/grant-slaves.sql'
    source 'grant.slave.erb'
    owner 'root'
    group 'root'
    mode '0600'
    variables(
    user: node['percona']['server']['replication']['username'],
    password: passwords.replication_password,
    host: slave
    )
    action :create
    notifies :run, 'execute[grant-slave]', :immediately
  end
end

node.set_unless['percona']['master'] = best_ip_for(node)

tag('percona_master')
