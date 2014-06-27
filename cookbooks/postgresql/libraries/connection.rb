module ChefUtils
  module PostgreSQL
    module Connection

      def connection
        Gem.clear_paths
        require 'pg'
        pg_pass = get_password("postgresql/postgres")
        @connection ||= ::PGconn.connect('127.0.0.1', 5432, nil, nil, nil, 'postgres', pg_pass)
      end

      def close
        @connection.finish rescue nil
        @connection = nil
      end

    end
  end
end
