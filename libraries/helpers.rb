module PerconaCookbook
  # Helper methods to be used in Percona-Multi cookbook libraries
  module Helpers

    def local_client
      @local_client ||=
        Mysql2::Client.new(
          host: new_resource.host,
          username: new_resource.root_user,
          password: new_resource.rootpasswd,
          port: new_resource.port
        )
    end

    def close_local_client
      @local_client.close if @local_client
    rescue Mysql2::Error
      @local_client = nil
    end

    def master_info(host, username, password)
      fil = ""
      pos = ""
      client = Mysql2::Client.new(:host => host, :username => username, :password => password)
      results = client.query("show master status")
      results.each do |row|
        fil = row["File"]
        pos = row["Position"]
      end
      return fil, pos
    end
  end
end
