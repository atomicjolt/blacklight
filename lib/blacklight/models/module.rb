module Blacklight
  class Module
    def initialize
      @identifier = ""
      @title = ""
      @module_items = ""
    end

    def canvas_conversion(course)
      cc_module = CanvasCc::CanvasCC::Models::CanvasModule.new
      cc_module.identifier = @identifier
      cc_module.title = @title
      cc_module.workflow_state = "published"
      cc_module.identifier = @identifier
      course.canvas_modules << cc_module
      course
    end
  end
end
