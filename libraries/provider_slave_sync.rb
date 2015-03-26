class Chef
  class Provider
    # Connects MySQL slave server to the master server
    class PerconaSlaveSync < Chef::Provider::LWRPBase
      include PerconaCookbook::Helpers

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        unless ::File.exist?("#{new_resource.data_dir}/.replication")
          # Calls helpers to grab binlog and binpos from master server
          if Chef::Config[:solo]
            Chef::Log.warn('This feature only works on a chef server not chef solo.')
          else
            fil, pos = master_info(new_resource.master_ip, new_resource.repluser, new_resource.replpasswd)
            Chef::Log.warn("Utilizing Binlog #{fil} and Position #{pos}"
          end

          # Sets master info and starts slave service
          begin
            set_mstr = "CHANGE MASTER TO MASTER_HOST='#{new_resource.master_ip}', "
            set_mstr += "MASTER_USER='#{new_resource.repluser}', MASTER_PASSWORD='#{new_resource.replpasswd}', "
            set_mstr += "MASTER_LOG_FILE='#{fil}', MASTER_LOG_POS=#{pos}, MASTER_CONNECT_RETRY=10;"
            p set_mstr
            local_client.query(set_mstr)
            local_client.query('START SLAVE;')
          ensure
            close_local_client
          end

          # drop guard file to keep replication from resetting on every chef run
          template '.replication' do
            path "#{new_resource.data_dir}/.replication"
            source 'replication_flag.erb'
            owner 'root'
            group 'root'
            mode '0600'
            action :create_if_missing
          end
        end
      end
    end
  end
end
