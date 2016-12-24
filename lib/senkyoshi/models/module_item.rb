require "senkyoshi/models/resource"

module Senkyoshi
  class ModuleItem < Resource
    def initialize(title, type, identifierref)
      @title = title
      @identifier = Senkyoshi.create_random_hex
      @content_type = type
      @identifierref = identifierref
      @workflow_state = "active"
    end

    def canvas_conversion(*)
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
