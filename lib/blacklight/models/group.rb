require "blacklight/models/resource"

module Blacklight
  class Group < Resource
    def initialize
      @name = ""
      @description = ""
      @is_public = true
    end

    def iterate_xml(data)
      @name = Blacklight.get_attribute_value(data, "TITLE")
      @description = data.at("TEXT").children.text
      @is_public = Blacklight.get_attribute_value(data, "ISAVAILABLE")
      self
    end

    def canvas_conversion(course, _resources)
      course
    end
  end
end
