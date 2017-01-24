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
        master_module = course.canvas_modules.
          detect { |a| a.title == "master_module" }
        if master_module
          master_module.module_items << @module_item
        else
          master_module = Module.new("master_module", "master_module")
          master_module = master_module.canvas_conversion
          master_module.module_items << @module_item
          course.canvas_modules << master_module
        end
      end
      course
    end
  end
end
