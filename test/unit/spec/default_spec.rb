# Encoding: utf-8

require_relative 'spec_helper'

describe 'percona-multi::master' do
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
          end.converge(described_recipe)
        end

        it 'includes the percona::server recipe' do
          expect(chef_run).to include_recipe('percona::server')
        end
      end
    end
  end
end
