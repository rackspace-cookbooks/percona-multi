# Encoding: utf-8
require 'chefspec'
require 'chefspec/berkshelf'

def stub_resources
  stub_command("mysqladmin --user=root --password='' version").and_return(true)
  stub_command('rpm -qa | grep Percona-Server-shared-56').and_return(true)
end

at_exit { ChefSpec::Coverage.report! }
