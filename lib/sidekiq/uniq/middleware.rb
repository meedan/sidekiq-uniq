require 'sidekiq/uniq/status'

module Sidekiq
  module Uniq

    class ClientMiddleware

      # Runs before job is added to queue

      def call(worker_class, msg, queue_name, redis_pool)
        unless msg['unique'] === false
          return false if Status.running_or_enqueued(msg, redis_pool)
          Status.save_status(msg, :enqueued, redis_pool)
        end
        yield
      end
    end

    class ServerMiddleware
    
      # Runs before job is executed

      def call(worker_class, msg, queue_name)
        Status.save_status(msg, :running)
        yield
        Status.save_status(msg, :completed)
      end
    end

  end
end
