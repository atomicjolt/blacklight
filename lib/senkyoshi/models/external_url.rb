require "senkyoshi/models/content"

module Senkyoshi
  class ExternalUrl < Content
    def canvas_conversion(course, _resource)
      create_module(course)
    end

    def set_module
      module_item = ModuleItem.new(@title, @module_type, @id, @url)
      module_item.canvas_conversion
    end
  end
end
