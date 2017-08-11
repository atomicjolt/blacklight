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
  class Forum < FileResource
    def initialize(resource_id)
      super(resource_id)
      @title = ""
      @text = ""
      @discussion_type = "threaded"
    end

    def iterate_xml(data, pre_data)
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @text = Senkyoshi.get_text(data, "TEXT")
      if pre_data[:internal_handle]
        @module_item = ModuleItem.new(
          @title,
          "DiscussionTopic",
          @id,
          nil,
          pre_data[:indent],
          @id,
        ).canvas_conversion
      end
      self
    end

    def canvas_conversion(course, _resources = nil)
      discussion = CanvasCc::CanvasCC::Models::Discussion.new
      discussion.title = @title
      discussion.text = @text
      discussion.identifier = @id
      discussion.discussion_type = @discussion_type
      course.discussions << discussion
      if @module_item
        course = create_module(course)
      end
      course
    end
  end
end
