require "senkyoshi/models/resource"

module Senkyoshi
  class Blog < Resource
    def initialize
      @title = ""
      @description = ""
      @is_public = true
    end

    def iterate_xml(data, _)
      @name = Senkyoshi.get_attribute_value(data, "TITLE")
      @description = data.at("TEXT").text
      @is_public = Senkyoshi.get_attribute_value(data, "ISAVAILABLE")
      self
    end

    def canvas_conversion(course, _resources = nil)
      course
    end
  end
end
