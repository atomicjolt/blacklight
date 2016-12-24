module Senkyoshi
  class Quiz < Content
    def canvas_conversion(course, _resource)
      create_module(course)
    end
  end
end
