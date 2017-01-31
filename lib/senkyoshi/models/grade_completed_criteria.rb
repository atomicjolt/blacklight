require "senkyoshi/models/grade_criteria"
module Senkyoshi
  class GradeCompletedCriteria < GradeCriteria
    def get_completion_type
      COMPLETION_TYPES[:must_submit]
    end
  end
end
