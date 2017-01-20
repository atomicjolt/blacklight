require "senkyoshi/models/root_resource"

module Senkyoshi
  class Forum < RootResource
    def initialize(resource_id)
      super(resource_id)
      @title = ""
      @text = ""
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
      discussion.identifier = @id
      discussion.discussion_type = @discussion_type
      course.discussions << discussion
      course
    end
  end
end
