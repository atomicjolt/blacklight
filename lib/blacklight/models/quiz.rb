module Blacklight
  class Quiz < Content
    def canvas_conversion(course)
      create_module(course)
    end
  end
end
