module Blacklight
  class ModuleItem
    def initialize
      @title = ""
      @identifier = ""
      @content_type = ""
      # WikiPage, Attachment, ContextModuleSubHeader, DiscussionTopic
      # Assignment, Quizzes::Quiz, ExternalUrl
    end

    def canvas_conversion(cc_module)
      module_item = CanvasCc::CanvasCC::Models::ModuleItem.new
      module_item.title = @title
      module_item.identifier = @identifier
      module_item.content_type = @content_type
      module_item.workflow_state = "published"
      cc_module.items << module_item
      cc_module
    end
  end
end
