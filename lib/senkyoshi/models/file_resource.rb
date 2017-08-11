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

require "senkyoshi/models/resource"

module Senkyoshi
  ##
  # Class to represent a resource constructed from a single 'dat' file.
  ##
  class FileResource < Resource
    attr_reader(:id)

    def initialize(id = nil)
      @id = id
    end

    def self.from(xml, pre_data, _resource_xids = nil)
      resource = new(pre_data[:file_name])
      resource.iterate_xml(xml, pre_data)
    end

    def iterate_xml(_xml, _pre_data)
      self
    end

    def create_module(course)
      course.canvas_modules ||= []
      cc_module = Course.master_module(course)
      if cc_module
        cc_module.module_items << @module_item
      else
        cc_module = Module.new(MASTER_MODULE, MASTER_MODULE)
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
        course.canvas_modules << cc_module
      end
      course
    end
  end
end
