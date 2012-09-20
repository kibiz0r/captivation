module Captivation
  module Captivates
    attr_streamer :created_instances

    def captivates(*dependencies)
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
  end
end
