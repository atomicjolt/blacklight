require "senkyoshi/models/resource"

module Senkyoshi
  class ModuleItem < Resource
    def initialize(title, type, identifierref, item = nil)
      @title = title
      @identifier = Senkyoshi.create_random_hex
      @content_type = type
      @identifierref = identifierref
      @workflow_state = "active"
      @item = item
    end

    def canvas_conversion(*)
      CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
        item.title = @title
        item.identifier = @identifier
        item.content_type = @content_type
        item.identifierref = @identifierref
        item.workflow_state = @workflow_state

        if @content_type == "Attachment"
          item.identifierref = @item.files.first.linkname
          # byebug
        end

        if @content_type == "ExternalUrl"
          item.url = @item.url
        end
      end
    end
  end
end
