module Blacklight
  class Blog
    def initialize
      @title = ""
      @description = ""
      @is_public = true
    end

    def iterate_xml(data, _)
      @name = Blacklight.get_attribute_value(data, "TITLE")
      @description = data.at("TEXT").text
      @is_public = Blacklight.get_attribute_value(data, "ISAVAILABLE")
      self
    end

    def canvas_conversion(course)
      course
    end
  end
end
