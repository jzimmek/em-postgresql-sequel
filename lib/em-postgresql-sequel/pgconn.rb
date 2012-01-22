module Sequel
  module Postgres
    class ::PGconn
      def async_exec(sql, args=nil)
        send_query(sql, args)

        deferrable = ::EM::DefaultDeferrable.new
        ::EM.watch(self.socket, EM::Sequel::Postgres::Watcher, self, deferrable).notify_readable = true
        
        f = Fiber.current
        
        deferrable.callback do |res| 
          # puts "!!! callback: #{res}"
          
          # check for alive?, otherwise we probably resume a dead fiber, because someone has killed our session e.g. "select pg_terminate_backend('procpid');"
          f.resume(res) if f.alive?
        end
        
        deferrable.errback  do |err| 
          # puts "!!! errback: #{err}"

          # check for alive?, otherwise we probably resume a dead fiber, because someone has killed our session e.g. "select pg_terminate_backend('procpid');"
          f.resume(err) if f.alive?
        end
    
        Fiber.yield.tap do |result|
          raise result if result.is_a?(Exception)
        end
        
      end
    end
  end
end
