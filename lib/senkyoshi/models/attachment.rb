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

require "senkyoshi/models/content"
require "senkyoshi/models/module_item"

module Senkyoshi
  class Attachment < Content
    def iterate_xml(xml, pre_data)
      super
      @module_item = ModuleItem.new(
        @title,
        @module_type,
        @files.first.name,
        @url,
        @indent,
        @file_name,
      ).canvas_conversion
      self
    end

    def canvas_conversion(course, _resource)
      create_module(course)
    end
  end
end
