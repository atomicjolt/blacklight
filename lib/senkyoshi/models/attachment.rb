require "senkyoshi/models/content"
require "byebug"

module Senkyoshi
  class Attachment < Content
    def canvas_conversion(course, _resource)
      create_module(course)
    end
  end
end
