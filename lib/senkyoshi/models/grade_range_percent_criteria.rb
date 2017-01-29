require "senkyoshi/models/grade_range_criteria"

module Senkyoshi
  class GradeRangePercentCriteria < GradeRangeCriteria
    def make_completion(mod)
      super(mod).tap do |completion_requirement|
        completion_requirement.min_score = get_percentage(
          @min_score,
          @points_possible,
        )
      end
    end

    def get_points_possible(resources, id)
      resource = resources.find_by_id(id)
      resource.points_possible if resource
    end

    def get_percentage(min_score, points_possible)
      possible = points_possible.to_f
      (min_score.to_f / possible) * possible
    end

    def canvas_conversion(course, content_id, resources)
      @points_possible = get_points_possible(resources, @asidata_id)

      super(course, content_id, resources)
    end
  end
end
