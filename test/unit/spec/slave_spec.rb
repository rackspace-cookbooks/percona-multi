# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'percona-multi::slave' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['percona']['server']['includedir'] = '/etc/mysql/conf.d/'
            node.set['percona']['server']['role'] = ['slave']
            node.set['percona']['master'] = '1.2.3.4'
            node.set['percona']['slaves'] = ['5.6.7.8']
            node.set['percona']['server']['replication']['password'] = 'test123'
            @log = 'mysqlbin-0001'
            @pos = 1492
          end.converge(described_recipe)
        end

        property = load_platform_properties(platform: platform, platform_version: version)

        let(:change_master_content) do
          "CHANGE MASTER TO MASTER_HOST='1.2.3.4',MASTER_USER='replicant', MASTER_PASSWORD='test123', MASTER_LOG_FILE='', MASTER_LOG_POS=, MASTER_CONNECT_RETRY=10;\nSTART SLAVE;"
        end

        it 'install mysql via chef_gem' do
          expect(chef_run).to install_chef_gem('mysql')
        end

        it 'creates a slave config' do
          expect(chef_run).to create_template('/etc/mysql/conf.d/slave.cnf')
        end

        it 'executes set master' do
          expect(chef_run).to_not run_execute('set_master')
        end

        it 'creates change master template' do
          expect(chef_run).to create_template('/root/change.master.sql').with(
          owner: 'root',
          group: 'root',
          mode: '0600',
          path: '/root/change.master.sql'
          )
          expect(chef_run).to render_file('/root/change.master.sql').with_content(change_master_content)
        end

        it 'executes change master' do
          expect(chef_run).to_not run_execute('change master')
        end

        it 'set guard template file' do
          expect(chef_run).to create_template_if_missing('/var/lib/mysql/.replication')
        end

      end
    end
  end
end
