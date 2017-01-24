require "senkyoshi/models/file_resource"

module Senkyoshi
  class Forum < FileResource
    def initialize(resource_id)
      super(resource_id)
      @title = ""
      @text = ""
      @discussion_type = "threaded"
    end

    def iterate_xml(data, pre_data)
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @text = Senkyoshi.get_text(data, "TEXT")
      if !pre_data.empty?
        @module_item = ModuleItem.new(
          @title,
          "DiscussionTopic",
          @identifier,
          nil,
          pre_data[:indent],
          pre_data[:file_name],
        ).canvas_conversion
      end
      self
    end

    def canvas_conversion(course, _resources = nil)
      discussion = CanvasCc::CanvasCC::Models::Discussion.new
      discussion.title = @title
      discussion.text = @text
      discussion.identifier = @id
      discussion.discussion_type = @discussion_type
      course.discussions << discussion
      if @module_item
        course = create_module(course, @module_item)
      end
      course
    end
  end
end
