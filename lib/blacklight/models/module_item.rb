module Blacklight
  class ModuleItem
    def initialize(title, type, identifierref)
      @title = title
      @identifier = Blacklight.create_random_hex
      @content_type = type
      @identifierref = identifierref
      @workflow_state = "active"
      self.canvas_conversion
    end

    def canvas_conversion
      CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
        item.title = @title
        item.identifier = @identifier
        item.content_type = @content_type
        item.identifierref = @identifierref
        item.workflow_state = @workflow_state
      end
    end
  end
end
