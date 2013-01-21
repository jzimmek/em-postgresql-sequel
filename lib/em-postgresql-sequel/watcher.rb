module EM
  module Sequel
    module Postgres
      module Watcher
        def initialize(client, deferrable)
          @client = client
          @deferrable = deferrable
        end

        def notify_readable
          @client.consume_input
          unless @client.is_busy
            detach
            begin
              @deferrable.succeed(@client.get_last_result)
            rescue Exception => e
              @deferrable.fail(e)
            end
          end
        end
      end
    end
  end
end
