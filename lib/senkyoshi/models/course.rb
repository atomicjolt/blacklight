require "senkyoshi/models/file_resource"

module Senkyoshi
  class Course < FileResource
    ##
    # This class represents a reader for one zip file, and allows the usage of
    # individual files within zip file
    ##
    def initialize(resource_id = nil)
      super(resource_id)
      @course_code = ""
      @title = ""
      @description = ""
      @is_public = false
      @start_at = ""
      @conclude_at = ""
    end

    def iterate_xml(data, _)
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @description = Senkyoshi.get_description(data)
      @is_public = Senkyoshi.get_attribute_value(data, "ISAVAILABLE")
      @start_at = Senkyoshi.get_attribute_value(data, "COURSESTART")
      @conclude_at = Senkyoshi.get_attribute_value(data, "COURSEEND")
      self
    end

    def canvas_conversion(course, _resources = nil)
      course.identifier = @id
      course.title = @title
      course.description = @description
      course.is_public = @is_public
      course.start_at = @start_at
      course.conclude_at = @conclude_at
      course
    end

    def self.master_module(course)
      course.canvas_modules.detect { |a| a.title == MASTER_MODULE }
    end
  end
end
