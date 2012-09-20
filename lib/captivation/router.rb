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

    def shared_channels
      @shared_channels ||= []
    end

    def share(channel)
      shared_channels << channel
    end

    def shared?(channel)
      shared_channels.include? channel
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
      @capture_stream ||= fire_stream.reject do |source_stream, event, *args|
        denied? event
      end
    end

    def public_capture_stream
      @public_capture_stream ||= capture_stream.reject do |source_stream, event, *args|
        source_stream == public_fire_stream
      end.map do |source_stream, event, *args|
        [event, *args]
      end.reject do |event, *args|
        blocked? event
      end
    end

    def private_capture_stream
      @private_capture_stream ||= capture_stream.reject do |source_stream, event, *args|
        source_stream == private_fire_stream
      end.map do |source_stream, event, *args|
        [event, *args]
      end
    end

    def named_capture_stream(name)
      @named_capture_streams ||= {}
      @named_capture_streams[name] ||= capture_stream.reject do |source_stream, event, *args|
        source_stream == named_fire_stream(name)
      end.map do |source_stream, event, *args|
        [event, *args]
      end.where do |event, *args|
        shared? name
      end
    end

    def fire_stream
      @fire_stream ||= Reactr::Streamer.new
    end

    def public_fire_stream
      @public_fire_stream ||= Reactr::Streamer.new.tap do |streamer|
        streamer.map do |event, *args|
          [streamer, event, *args]
        end.subscribe fire_stream
      end
    end

    def private_fire_stream
      @private_fire_stream ||= Reactr::Streamer.new.tap do |streamer|
        streamer.map do |event, *args|
          [streamer, event, *args]
        end.subscribe fire_stream
      end
    end

    def named_fire_stream(name)
      @named_fire_streams ||= {}
      @named_fire_streams[name] ||= Reactr::Streamer.new.tap do |streamer|
        streamer.reject do |event, *args|
          ignored? event, name
        end.map do |event, *args|
          [streamer, event, *args]
        end.subscribe fire_stream
      end
    end

    def public_channel
      @public_channel ||= Captivation::Channel.new public_capture_stream,
        Reactr::Streamer.new.tap { |streamer| streamer.subscribe public_fire_stream }
    end

    def private_channel
      @private_channel ||= Captivation::Channel.new private_capture_stream, private_fire_stream
    end

    def named_channel(name)
      @named_channels ||= {}
      @named_channels[name] ||= Captivation::Channel.new named_capture_stream(name),
        Reactr::Streamer.new.tap { |streamer| streamer.subscribe named_fire_stream(name) }
    end
  end
end
