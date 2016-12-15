module Blacklight
  class Course
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
      @title = Blacklight.get_attribute_value(data, "TITLE")
      @description = Blacklight.get_description(data)
      @is_public = Blacklight.get_attribute_value(data, "ISAVAILABLE")
      @start_at = Blacklight.get_attribute_value(data, "COURSESTART")
      @conclude_at = Blacklight.get_attribute_value(data, "COURSEEND")
      self
    end

    def canvas_conversion(course)
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
