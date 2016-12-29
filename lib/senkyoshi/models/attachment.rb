require "senkyoshi/models/content"
require "byebug"

module Senkyoshi
  class Attachment < Content
    def iterate_xml(xml, pre_data)
      super
      @id = @files.first.linkname
      @module_item = set_module if @module_type
      self
    end

    def canvas_conversion(course, _resource)
      create_module(course)
    end
  end
end
