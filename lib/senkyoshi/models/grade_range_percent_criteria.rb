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
