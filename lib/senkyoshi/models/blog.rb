require "senkyoshi/models/root_resource"

module Senkyoshi
  class Blog < RootResource
    def initialize(resource_id)
      super(resource_id)
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
