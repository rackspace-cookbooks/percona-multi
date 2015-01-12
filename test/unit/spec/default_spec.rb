# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'templatestack::default' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        property = load_platform_properties(platform: platform, platform_version: version)

        it "#{property} rspec authoriti" do
          expect(chef_run).to write_log('lions, tigers and bears!')
          expect(chef_run).to_not write_log('lions, tigers')
        end
      end
    end
  end
end
