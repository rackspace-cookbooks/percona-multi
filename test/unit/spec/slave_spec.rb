# Encoding: utf-8

require_relative 'spec_helper'

describe 'percona-multi::slave' do
  before do
    allow(::File).to receive(:symlink?).and_return(false)
  end

  platforms = {
    'ubuntu' => ['12.04', '14.04'],
    'centos' => ['6.6', '7.0']
  }

  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['percona']['server']['includedir'] = '/etc/mysql/conf.d/'
            node.set['percona']['server']['role'] = ['slave']
            node.set['percona']['master'] = '1.2.3.4'
            node.set['percona']['slaves'] = ['5.6.7.8']
            node.set['percona']['server']['replication']['password'] = 'test123'
          end.converge(described_recipe)
        end

        it 'includes the percona::server recipe' do
          expect(chef_run).to include_recipe('percona::server')
        end

        it 'includes the percona::client recipe' do
          expect(chef_run).to include_recipe('percona::client')
        end

        it 'installs mysql2_chef_gem' do
          expect(chef_run).to install_mysql2_chef_gem('default')
        end

        it 'create default percona config' do
          expect(chef_run).to create_percona_config('slave replication')
        end

        it 'create default percona slave sync' do
          expect(chef_run).to create_percona_slave_sync('default')
        end
      end
    end
  end
end
