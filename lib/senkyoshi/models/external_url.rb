require "senkyoshi/models/content"

module Senkyoshi
  class ExternalUrl < Content
    def canvas_conversion(course, _)
      create_module(course)
    end
  end
end
