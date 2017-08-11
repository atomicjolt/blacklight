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
require "senkyoshi/models/assignment_group"

module Senkyoshi
  class OutcomeDefinition < Resource
    include Senkyoshi
    attr_reader :id, :content_id, :asidataid, :is_user_created
    def self.from(xml, category, id = nil)
      outcome_definition = OutcomeDefinition.new(category, id)
      outcome_definition.iterate_xml(xml)
    end

    def initialize(category, id, content_id = nil, asidataid = nil)
      @id = id
      @content_id = content_id
      @asidataid = asidataid
      @category = category
    end

    def iterate_xml(xml)
      @content_id = xml.xpath("./CONTENTID/@value").text
      @asidataid = xml.xpath("./ASIDATAID/@value").text
      @id = xml.xpath("./@id").text
      @title = xml.xpath("./TITLE/@value").text
      @points_possible = xml.xpath("./POINTSPOSSIBLE/@value").text
      @is_user_created = Senkyoshi.true?(
        xml.xpath("./ISUSERCREATED/@value").text,
      )
      self
    end

    ##
    # Determine if an outcome definition is user created and linked to any
    # other 'CONTENT' or assignments
    ##
    def self.orphan?(outcome_def)
      outcome_def.content_id.empty? &&
        outcome_def.asidataid.empty? &&
        outcome_def.is_user_created
    end

    def canvas_conversion(course, _ = nil)
      assignment_group = AssignmentGroup.find_or_create(course, @category)
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = @id
      assignment.assignment_group_identifier_ref = assignment_group.identifier
      assignment.title = @title
      assignment.position = 1
      assignment.points_possible = @points_possible
      assignment.workflow_state = "published"
      assignment.grading_type = "points"

      course.assignments << assignment
      course
    end
  end
end
