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

require "senkyoshi/models/grade_criteria"

module Senkyoshi
  class GradeRangeCriteria < GradeCriteria
    attr_reader(:min_score)

    def initialize(id, outcome_def_id, negated, min_score)
      super(id, outcome_def_id, negated)
      @min_score = min_score
    end

    def self.get_min_score(xml)
      xml.xpath("./MIN_SCORE/@value").text
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = Senkyoshi.true? RuleCriteria.get_negated xml
      outcome_def_id = GradeCriteria.get_outcome_def_id xml
      min_score = GradeRangePercentCriteria.get_min_score xml
      new(id, outcome_def_id, negated, min_score)
    end

    def get_completion_type
      COMPLETION_TYPES[:min_score]
    end

    def make_completion(mod)
      super(mod).tap do |completion_requirement|
        completion_requirement.min_score = @min_score
      end
    end
  end
end
