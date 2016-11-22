module Blacklight
  class Forum
    def initialize
      @title = ""
      @text = ""
      @identifier = Blacklight.create_random_hex
      @discussion_type = "threaded"
    end

    def iterate_xml(data)
      @title = Blacklight.get_attribute_value(data, "TITLE")
      @text = Blacklight.get_text(data, "TEXT")
      self
    end

    def canvas_conversion(course)
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
