require "senkyoshi/models/content"

module Senkyoshi
  class Quiz < Content
    def canvas_conversion(course, _resource)
      create_module(course)
    end

    def set_module
      @module_type = "Quizzes::Quiz"
      super
    end
  end
end
