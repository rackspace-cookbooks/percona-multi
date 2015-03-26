class Chef
  class Resource
    # Used to setup permissions for Percona replication user on master server
    class PerconaConfig < Chef::Resource::LWRPBase
      self.resource_name = :percona_config
      actions :create
      default_action :create

      attribute :config_name, kind_of: String, name_attribute: true, required: true
      attribute :cookbook, kind_of: String, default: nil
      attribute :group, kind_of: String, default: 'mysql'
      attribute :include_dir, kind_of: String, default: '/etc/mysql/conf.d'
      attribute :owner, kind_of: String, default: 'mysql'
      attribute :source, kind_of: String, default: nil
      attribute :variables, kind_of: [Hash], default: nil
      attribute :version, kind_of: String, default: nil
    end
  end
end
