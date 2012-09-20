module Captivation
  module Captivate
    def initialize(*args, &block)
      super if defined?(super) && self.class.superclass != Object
      captivate! *args, &block
    end

    def captivate!(*args, &block)
      opts = args.extract_options!
      self.class.captivated_attr_map.each do |dependency_name, attr|
        ivar = :"@#{attr}"

        they = instance_variable_get(ivar).router.public_channel # us their public channel
        we = router.named_channel dependency_name # us our named channel

        they.subscribe we
        we.subscribe they
      end
    end
  end
end
