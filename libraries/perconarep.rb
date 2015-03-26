class Chef
  class Recipe
    # Run mysql client, grab binlog and binpos and pass back as variables
    class PerconaRep
      def self.query(host, username, password, query)
        require 'rubygems'
        require 'mysql2'
        m = Mysql2.new(host, username, password)
        r = m.query(query)
        return r.fetch_hash
      end
      def self.bininfo(host, username, password)
        h = query(host, username, password, 'show master status')
        p h
        log = h['File']
        pos = h['Position']
        return log, pos
      end
    end
  end
end
