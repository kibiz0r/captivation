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

        they = instance_variable_get(ivar).router.public_channel # use their public channel
        we = router.named_channel dependency_name # use our named channel

        we.connect they
      end
    end
  end
end
