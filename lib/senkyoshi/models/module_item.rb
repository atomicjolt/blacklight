require "senkyoshi/models/resource"

module Senkyoshi
  class ModuleItem < Resource
    def initialize(title, type, identifierref, url, indent, id)
      @title = title
      @identifier = id || Senkyoshi.create_random_hex
      @content_type = type
      @identifierref = identifierref
      @indent = indent
      @workflow_state = "active"
      @url = url
    end

    def canvas_conversion(*)
      CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
        item.title = @title
        item.identifier = @identifier
        item.content_type = @content_type
        item.identifierref = @identifierref
        item.workflow_state = @workflow_state
        item.indent = @indent
        item.url = @url
      end
    end
  end
end
