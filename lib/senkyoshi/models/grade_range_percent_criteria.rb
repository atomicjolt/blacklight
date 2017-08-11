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

require "senkyoshi/models/grade_range_criteria"

module Senkyoshi
  class GradeRangePercentCriteria < GradeRangeCriteria
    def make_completion(mod)
      super(mod).tap do |completion_requirement|
        completion_requirement.min_score = GradeRangePercentCriteria.
          get_percentage(@min_score, @points_possible)
      end
    end

    def get_points_possible(resources, id)
      resource = resources.find_by_id(id)
      resource.points_possible if resource
    end

    def self.get_percentage(min_score, points_possible)
      (min_score.to_f / 100) * points_possible.to_f
    end

    def canvas_conversion(course, content_id, resources)
      set_foreign_ids(resources, @outcome_def_id)
      @points_possible = get_points_possible(resources, get_foreign_id)

      super(course, content_id, resources)
    end
  end
end
