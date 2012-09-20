module Captivation
  class Channel
    include Reactr::Streamable

    def initialize(broadcaster = nil, subscriber = nil)
      if broadcaster && subscriber
        @my_broadcaster = Reactr::Streamer.new
        @my_broadcaster.subscribe subscriber
        @my_subscriptions = Reactr::Stream.new broadcaster
      else
        @my_broadcaster = Reactr::Streamer.new
        @my_subscriptions_proxy = Reactr::Streamer.new
        @my_subscriptions = Reactr::Stream.new @my_subscriptions_proxy

        @doppleganger = self.class.new @my_broadcaster, @my_subscriptions_proxy
        @doppleganger.instance_variable_set :@doppleganger, self

        @my_subscriptions.subscribe subscriber if subscriber
        broadcaster.subscribe @my_broadcaster if broadcaster
      end
    end

    def doppleganger
      @doppleganger
    end

    def <<(value)
      @my_broadcaster << value
    end

    def done
      @my_broadcaster.done
    end

    def error(error)
      @my_broadcaster.error error
    end

    def subscribe(*args)
      @my_subscriptions.subscribe *args
    end
  end
end
