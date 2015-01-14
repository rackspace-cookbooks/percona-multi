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

node.default['percona']['server']['includedir'] = '/etc/mysql/conf.d/'

node.default['build-essential']['compile_time'] = true
node.default['apt']['compile_time_update'] = true

include_recipe 'apt' if platform_family?('debian')
include_recipe 'build-essential'
include_recipe 'percona::server'

# adds directory if not created by service (only needed on rhel)
if platform_family?('rhel')
  directory '/etc/mysql/conf.d' do
    owner 'mysql'
    group 'mysql'
    action :create
  end
end

# mysql gem must be installed at compile time to run replication script, but only on first run
unless File.exist?("#{node['percona']['server']['datadir']}/.replication")
  case node['platform_family']
  when 'debian'
    potentially_at_compile_time do
      package 'libmysqlclient-dev'
    end
  when 'rhel'
    potentially_at_compile_time do
      package 'mysql-devel'
    end
  end
  chef_gem 'mysql' do
    action :install
  end
end

# creates unique serverid via ipaddress to an int
require 'ipaddr'
serverid = IPAddr.new node['ipaddress']
serverid = serverid.to_i

passwords = EncryptedPasswords.new(node, node['percona']['encrypted_data_bag'])

# drop MySQL slave specific configuration file
template "#{node['percona']['server']['includedir']}slave.cnf" do
  cookbook node['percona']['replication']['templates']['slave.cnf']['cookbook']
  source node['percona']['replication']['templates']['slave.cnf']['source']
  variables(
  cookbook_name: cookbook_name,
  serverid: serverid
  )
  notifies :restart, 'service[mysql]', :immediately
end

# pull data from master, but only on first run
host = node['percona']['master']
user = node['percona']['server']['replication']['username']
passwd = passwords.replication_password

unless File.exist?("#{node['percona']['server']['datadir']}/.replication")
  if Chef::Config[:solo]
    Chef::Log.warn('This only works on a chef server not chef solo.')
  else
    log, pos = PerconaRep.bininfo(host, user, passwd)
    node.default['bin_log'] = log
    node.default['bin_pos'] = pos
    log "binlog- #{node['bin_log']} and binpos- #{node['bin_pos']}" do
      level :info
    end
  end
end

# create and execute slave replication setup
execute 'set_master' do
  command <<-EOH
  /usr/bin/mysql -u root -p'#{passwords.root_password}' < /root/change.master.sql
  rm -f /root/change.master.sql
  EOH
  action :nothing
end

template '/root/change.master.sql' do
  path '/root/change.master.sql'
  source 'change.master.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
  host: node['percona']['master'],
  user: node['percona']['server']['replication']['username'],
  binlog: node['bin_log'],
  binpos: node['bin_pos'],
  password: passwords.replication_password
  )
  notifies :run, 'execute[set_master]', :immediately
  not_if { File.exist?("#{node['percona']['server']['datadir']}/.replication") }
end

tag('percona_slave')

# drop guard file to keep replication from resetting on every chef run
template '.replication' do
  path "#{node['percona']['server']['datadir']}/.replication"
  source 'replication_flag.erb'
  owner 'root'
  group 'root'
  mode '0600'
  action :create_if_missing
end
