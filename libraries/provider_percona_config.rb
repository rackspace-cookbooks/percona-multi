class Chef
  class Provider
    # Used to configure additional configuration files in Percona
    class PerconaConfig < Chef::Provider::LWRPBase

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        template "#{new_resource.name} :create #{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
          path "#{new_resource.include_dir}/#{new_resource.config_name}.cnf"
          owner new_resource.owner
          group new_resource.group
          mode '0640'
          variables(new_resource.variables)
          source new_resource.source
          cookbook new_resource.cookbook
          action :create
        end
      end

      action :remove do
        file "#{new_resource.name} :delete #{new_resource.include_dir}/#{new_resource.config_name}.conf" do
          path "#{new_resource.include_dir}/#{new_resource.config_name}.conf"
          action :delete
        end
      end
    end
  end
end
