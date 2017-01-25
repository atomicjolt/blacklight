require "senkyoshi/models/grade_criteria"

module Senkyoshi
  class GradeRangePercentCriteria < GradeCriteria
    def get_completion_type
      COMPLETION_TYPES[:must_submit]
    end

    def make_completion(mod)
      # TODO set completion_requirement min score
      completion_requirement = super(mod)
    end
  end
end
