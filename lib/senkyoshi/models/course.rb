require "senkyoshi/models/resource"

module Senkyoshi
  class Course < Resource
    ##
    # This class represents a reader for one zip file, and allows the usage of
    # individual files within zip file
    ##
    def initialize
      @course_code = ""
      @identifier = ""
      @title = ""
      @description = ""
      @is_public = false
      @start_at = ""
      @conclude_at = ""
    end

    def iterate_xml(data, _)
      @identifier = data["id"]
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @description = Senkyoshi.get_description(data)
      @is_public = Senkyoshi.get_attribute_value(data, "ISAVAILABLE")
      @start_at = Senkyoshi.get_attribute_value(data, "COURSESTART")
      @conclude_at = Senkyoshi.get_attribute_value(data, "COURSEEND")
      self
    end

    def canvas_conversion(course, _resources = nil)
      course.identifier = @identifier
      course.title = @title
      course.description = @description
      course.is_public = @is_public
      course.start_at = @start_at
      course.conclude_at = @conclude_at
      course
    end
  end
end
