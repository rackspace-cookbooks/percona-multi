# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'
require 'json'

Dir['./test/unit/spec/support/**/*.rb'].sort.each { |f| require f }

::LOG_LEVEL = :fatal
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

def node_resources(node)
end

def stub_resources
  stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
  stub_command("test -f /etc/mysql/grants.sql").and_return(true)
  stub_command("rpm -qa | grep Percona-Server-shared-56").and_return(true)
end

at_exit { ChefSpec::Coverage.report! }
