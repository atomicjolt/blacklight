module Blacklight
  class ModuleItem
    attr_reader :item

    def initialize(title, type, identifier)
      # WikiPage, Attachment, ContextModuleSubHeader, DiscussionTopic
      # Assignment, Quizzes::Quiz, ExternalUrl
      @title = title
      @identifier = Blacklight.create_random_hex
      @content_type = type
      @identifierref = identifier
      @workflow_state = "active"
    end

    def canvas_conversion
      item = CanvasCc::CanvasCC::Models::ModuleItem.new
      item.title = @title
      item.identifier = @identifier
      item.content_type = @content_type
      item.identifierref = @identifierref
      item.workflow_state = @workflow_state
      item
    end
  end
end
