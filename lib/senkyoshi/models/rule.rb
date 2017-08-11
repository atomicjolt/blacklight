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

require "senkyoshi/models/grade_completed_criteria"
require "senkyoshi/models/content_reviewed_criteria"
require "senkyoshi/models/grade_range_criteria"
require "senkyoshi/models/grade_range_percent_criteria"
require "senkyoshi/models/resource"

module Senkyoshi
  class Rule < FileResource
    attr_reader(:title, :content_id, :criteria_list, :id)

    CRITERIA_MAP = {
      grade_completed_criteria: GradeCompletedCriteria,
      content_reviewed_criteria: ContentReviewedCriteria,
      grade_range_criteria: GradeRangeCriteria,
      grade_range_percent_criteria: GradeRangePercentCriteria,
    }.freeze

    def initialize(resource_id)
      super(resource_id)
      @criteria_list = []
    end

    def get_criteria_list(xml)
      xml.children.select { |child_xml| !child_xml.blank? }.
        map do |child_xml|
          criteria = CRITERIA_MAP[child_xml.name.downcase.to_sym]
          criteria.from_xml(child_xml) if !criteria.nil?
        end.compact
    end

    def iterate_xml(xml, _pre_data = nil)
      @title = xml.xpath("./TITLE/@value").text
      @content_id = xml.xpath("./CONTENT_ID/@value").text
      @id = xml.xpath("./@id").text
      @criteria_list = get_criteria_list(xml.xpath("./CRITERIA_LIST"))
      self
    end

    def canvas_conversion(course, _resources)
      @criteria_list.each do |criteria|
        criteria.canvas_conversion(course, @content_id, _resources)
      end
      course
    end
  end
end
