require "senkyoshi/models/resource"

module Senkyoshi
  class Forum < Resource
    def initialize
      @title = ""
      @text = ""
      @identifier = Senkyoshi.create_random_hex
      @discussion_type = "threaded"
    end

    def iterate_xml(data, _)
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @text = Senkyoshi.get_text(data, "TEXT")
      self
    end

    def canvas_conversion(course, _resources = nil)
      discussion = CanvasCc::CanvasCC::Models::Discussion.new
      discussion.title = @title
      discussion.text = @text
      discussion.identifier = @identifier
      discussion.discussion_type = @discussion_type
      course.discussions << discussion
      course
    end
  end
end
