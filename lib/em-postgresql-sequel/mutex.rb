module EM
  module Sequel
    class Mutex
      def initialize
        @waiting = []
        @current = nil
      end
      
      def synchronize
        if @current
          if @current == Fiber.current
            raise "already in synchronize" 
          else
            @waiting << Fiber.current
            Fiber.yield
          end
        end
        
        @current = Fiber.current
        
        begin
          yield if block_given?
        ensure
          @current = nil
          if waiting = @waiting.shift
            waiting.resume
          end
        end
      end
    end
  end
end