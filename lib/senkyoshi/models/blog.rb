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
  class Blog < FileResource
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
