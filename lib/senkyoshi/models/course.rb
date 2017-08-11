# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
