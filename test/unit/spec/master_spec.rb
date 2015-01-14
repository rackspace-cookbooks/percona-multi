# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'percona-multi::master' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node|
            node.set['percona']['server']['includedir'] = '/etc/mysql/conf.d/'
            node.set['percona']['server']['role'] = ['master']
            node.set['percona']['master'] = '1.2.3.4'
            node.set['percona']['slaves'] = ['5.6.7.8']
            node.set['percona']['server']['replication']['password'] = 'test123'
          end.converge(described_recipe)
        end

        property = load_platform_properties(platform: platform, platform_version: version)

        let(:grant_content) do
          "GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicant'@'5.6.7.8' IDENTIFIED BY 'test123';\nFLUSH PRIVILEGES;"
        end

        it 'creates a master config' do
          expect(chef_run).to create_template('/etc/mysql/conf.d/master.cnf')
        end

        it 'create grants template' do
          expect(chef_run).to create_template("/root/grant-slaves.sql").with(
          owner: 'root',
          group: 'root',
          mode: '0600',
          path: '/root/grant-slaves.sql'
          )
          expect(chef_run).to render_file('/root/grant-slaves.sql').with_content(grant_content)
        end

        it 'executes grant-slave' do
          expect(chef_run).to_not run_execute('grant-slave')
        end
      end
    end
  end
end
