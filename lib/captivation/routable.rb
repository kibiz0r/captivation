module Captivation
  module Routable
    def router
      @router ||= Captivation::Router.new
    end

    def capture(event, &handler)
      private_channel.where do |event, *args|
        event == event
      end.each &handler
    end

    def fire(event, *args)
      private_channel << [event, *args]
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      attr_streamer :created_instances

      def captures(event, &handler)
        instance_captures = created_instances.flat_map do |instance|
          instance.capture(event).map do |*args|
            [instance, *args]
          end
        end

        if block_given?
          instance_captures.each do |instance, *args|
            instance.instance_exec event, *args, &handler
          end
        else
          instance_captures
        end
      end

      def shares(*events)
        events.each do |event|
          instance_captures = created_instances.flat_map do |instance|
            instance.capture(event).map do |*args|
              [instance, *args]
            end
          end

          instance_captures.each do |instance, *args|
            instance.named_channels.each do |named_channel|
              named_channel << [event, *args]
            end
          end
        end
      end
    end
  end
end
