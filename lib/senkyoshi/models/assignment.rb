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

module Senkyoshi
  class Assignment < Content
    def canvas_conversion(course, resources)
      unless @title == "--TOP--"
        assignment = CanvasCc::CanvasCC::Models::Assignment.new
        assignment.identifier = @id
        assignment.title = @title
        assignment.body = fix_html(@body, resources)
        assignment.points_possible = @points
        assignment.assignment_group_identifier_ref = @group_id
        assignment.position = 1
        assignment.workflow_state = "published"
        assignment.submission_types << "online_text_entry"
        assignment.submission_types << "online_upload"
        assignment.grading_type = "points"

        @files.each do |file|
          assignment.body << file.canvas_conversion(resources)
        end
        course = create_module(course)
        course.assignments << assignment
      end
      course
    end
  end
end
