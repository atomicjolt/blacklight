module Blacklight
  class Module
    attr_accessor :module_items

    def initialize(title, id)
      @identifier = id
      @title = title
      @module_items = []
    end

    def canvas_conversion
      cc_module = CanvasCc::CanvasCC::Models::CanvasModule.new
      cc_module.identifier = @identifier
      cc_module.title = @title
      cc_module.workflow_state = "published"
      cc_module.module_items = @module_items
      cc_module
    end
  end
end
