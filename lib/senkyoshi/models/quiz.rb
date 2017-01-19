require "senkyoshi/models/content"

module Senkyoshi
  class Quiz < Content
    def canvas_conversion(course, _)
      create_module(course)
    end
  end
end
