module Captivation
  class Router
    def denied_events
      @denied_events ||= []
    end

    def denied?(event)
      @deny || denied_events.include?(event)
    end

    def deny(event = nil)
      if event
        denied_events << event
      else
        @deny = true
      end
    end

    def allow(event = nil)
      if event
        denied_events.delete event
      else
        @deny = false
      end
    end

    def blocked_events
      @blocked_events ||= []
    end

    def blocked?(event)
      @block || blocked_events.include?(event)
    end

    def block(event = nil)
      if event
        blocked_events << event
      else
        @block = true
      end
    end

    def unblock(event = nil)
      if event
        blocked_events.delete event
      else
        @block = false
      end
    end

    def shared?(event, on_channel)
      @shared_events ||= {}
      shares = @shared_events[event]
      case shares
      when true
        true
      when Array
        shares.include? on_channel
      else
        false
      end
    end

    def ignored_events
      @ignored_events ||= {}
    end

    def ignored?(event, on_channel)
      ignores = ignored_events[event]
      case ignores
      when true
        true
      when Array
        ignores.include? on_channel
      else
        false
      end
    end

    def ignore(event = nil, on_channel = nil)
      if event
        if on_channel
          unless ignored_events[event].is_a? Array
            ignored_events[event] = []
          end
          ignored_events[event] << on_channel
        else
          ignored_events[event] = true
        end
      else
        @ignore = true
      end
    end

    def capture_stream
      @capture_stream ||= fire_stream.reject do |event, *args|
        denied? event
      end
    end

    def fire_stream
      @fire_stream ||= Reactr::Streamer.new
    end

    def public_channel
      @resolving_events ||= []

      # Oh functional programming is a wonderful thing, look how declarative my code is!
      # I can barely tell what it's declaring, but by golly does it declare it...
      @public_channel ||= Captivation::Channel.new capture_stream.reject { |event, *args|
        blocked? event
      }.map { |event, *args|
        [event, *args].tap do
          @resolving_events << event
        end          
      }.reject { |event, *args|
        (@resolving_events.count(event) > 1).tap do |rejected|
          if rejected
            @resolving_events.delete event
          end
        end
      # }, fire_stream.map { |event, *args|
      #   [event, *args].tap do
      #     @resolving_events << event
      #   end
      # }.reject { |event, *args|
      #   @resolving_events.count(event) > 1
      # }
      }, Reactr::Streamer.new.tap { |streamer|
        streamer.map { |event, *args|
          [event, *args].tap do
            @resolving_events << event
          end
        }.reject { |event, *args|
          @resolving_events.count(event) > 1
        }.subscribe fire_stream
      }
    end

    def private_channel
      @private_channel ||= Captivation::Channel.new capture_stream, fire_stream
    end

    def named_channel(name)
      (@named_streams ||= Hash.new do |h, k|
        h[k] = Captivation::Channel.new capture_stream.where { |event, *args|
          shared? event, name
        }, Reactr::Streamer.new.tap { |streamer|
          streamer.reject { |event, *args|
            ignored? event, name
          }.subscribe fire_stream
        }
      end)[name]
    end
  end
end
