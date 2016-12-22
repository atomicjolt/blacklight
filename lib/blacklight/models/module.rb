require "blacklight/models/resource"

module Blacklight
  class Module < Resource
    attr_accessor :module_items

    def initialize(title, identifier)
      @identifier = identifier
      @title = title
      @module_items = []
    end

    def canvas_conversion(*)
      CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |cc_module|
        cc_module.identifier = @identifier
        cc_module.title = @title
        cc_module.workflow_state = "published"
        cc_module.module_items = @module_items
      end
    end
  end
end
