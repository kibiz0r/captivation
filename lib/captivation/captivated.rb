module Captivation
  module Captivated
    attr_streamer :created_instances

    def captivated(*dependencies)
      constructor *dependencies

      @captivated_attr_map = dependencies.extract_options!

      until dependencies.empty?
        dependency = dependencies.shift
        @captivated_attr_map[dependency] = dependency
      end

      include Captivation::Captivate
    end

    def captivated_attr_map
      super_attrs = superclass.try(:captivated_attr_map)._?({})
      super_attrs.merge(@captivated_attr_map ||= {})
    end

    def captivated_attrs
      captivated_attr_map.keys
    end

    def captures(event, &handler)
      instance_captures = created_instances.flat_map do |instance|
        instance.capture(event).map do |event, *args|
          [instance, event, *args]
        end
      end

      if block_given?
        instance_captures.each do |instance, event, *args|
          instance.instance_exec event, *args, &handler
        end
      else
        instance_captures
      end
    end

    def shares(event)
    end
  end
end
