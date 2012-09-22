module Captivation
  module Routable
    def router
      @router ||= Captivation::Router.new
    end

    def capture(event, &handler)
      stream = router.private_channel.where do |incoming_event, args|
        incoming_event == event
      end.map do |event, args|
        args
      end

      if block_given?
        stream.each &handler
      else
        stream
      end
    end

    def fire(event, *args)
      router.private_channel << [event, args]
    end

    def fire_at_will(success_and_maybe_failure, stream)
      success, failure = if success_and_maybe_failure.is_a? Array
                           success_and_maybe_failure
                         else
                           [
                             success_and_maybe_failure,
                             "never_#{success_and_maybe_failure}"
                           ]
                         end

      stream.inject [] do |args, arg|
        args << arg
      end.subscribe(
        each: lambda { |args|
          fire success, args
        },
        failure: lambda { |error|
          fire failure, error
        }
      )
    end

    module Initialize
      def initialize(*args, &block)
        super if defined?(super) && self.class.superclass != Object

        self.class.created_instances << self

        self.class.capture_handlers.each do |event, handlers|
          handlers.each do |handler|
            capture event do |args|
              instance_exec *args, &handler
            end
          end
        end

        self.class.share_events.each do |event|
          router.share event
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      attr_streamer :created_instances

      def capture_handlers
        @capture_handlers ||= {}
      end

      def captures(event, &handler)
        include Initialize
        capture_handlers[event] ||= []
        capture_handlers[event] << handler
      end

      def share_events
        @share_events ||= []
      end

      def shares(*events)
        include Initialize
        events.each do |event|
          share_events << event
        end
      end
    end
  end
end
