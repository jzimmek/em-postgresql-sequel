module EM
  module Sequel
    
    class FiberedConnectionPool < ::Sequel::ConnectionPool
      def initialize(*args)
        super
        @available = []
        @waiting = []
        
        opts = args.last
        Integer(opts[:max_connections] || 4).times do
          @available << make_new(DEFAULT_SERVER)
        end
        
        @mutex = Mutex.new
      end
      
      def disconnect(opts={}, &block)
        @mutex.synchronize do
          block ||= @disconnection_proc
          if block
            m = Mutex.new
            @available.each do |conn| 
              m.synchronize do
                block.call(conn)
              end
            end
          end
          @available.clear
        end
      end
      
      def size
        @available.length
      end
      
      def hold(server=nil, &blk)
        if @available.empty?
          @waiting << Fiber.current
          Fiber.yield
        end
        
        @waiting.delete Fiber.current
        conn = @available.pop
        
        begin
          blk.call(conn)
        rescue ::Sequel::DatabaseDisconnectError
          _conn = conn
          conn = nil
          @mutex.synchronize do
            @disconnection_proc.call(_conn) if @disconnection_proc && _conn
            @available << make_new(DEFAULT_SERVER)
          end
          raise
        ensure
          @available << conn if conn
          if waiting = @waiting.shift
            waiting.resume
          end
        end
      end
    end
    
  end
end