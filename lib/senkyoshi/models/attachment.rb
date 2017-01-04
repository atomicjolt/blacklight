require "senkyoshi/models/content"
require "senkyoshi/models/module_item"

module Senkyoshi
  class Attachment < Content
    def iterate_xml(xml, pre_data)
      super
      @module_item = ModuleItem.new(
        @title,
        @module_type,
        @files.first.name,
        @url,
      ).canvas_conversion
      self
    end

    def canvas_conversion(course, _resource)
      create_module(course)
    end

    def set_module
      module_item = ModuleItem.new(@title, @module_type, @id, @url)
      module_item.canvas_conversion
    end
  end
end
