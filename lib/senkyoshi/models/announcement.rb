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
  class Announcement < FileResource
    def initialize(resource_id)
      super(resource_id)
      @title = ""
      @text = ""
      @delayed_post = ""
      @posted_at = ""
      @dependency = Senkyoshi.create_random_hex
      @type = "announcement"
    end

    def iterate_xml(data, _)
      dates = data.children.at("DATES")
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @text = Senkyoshi.get_text(data, "TEXT")
      @delayed_post = Senkyoshi.get_attribute_value(dates, "RESTRICTSTART")
      @posted_at = Senkyoshi.get_attribute_value(dates, "CREATED")
      self
    end

    def canvas_conversion(course, resources)
      announcement = CanvasCc::CanvasCC::Models::Announcement.new
      announcement.title = @title
      announcement.text = fix_html(@text, resources)
      announcement.delayed_post = @delayed_post
      announcement.posted_at = @posted_at
      announcement.identifier = @id
      announcement.dependency = @dependency
      course.announcements << announcement
      course
    end
  end
end
