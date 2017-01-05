require "senkyoshi/models/content"

module Senkyoshi
  class Quiz < Content
    def canvas_conversion(course, _resource)
      create_module(course)
    end

    def set_module
      super
    end
  end
end
