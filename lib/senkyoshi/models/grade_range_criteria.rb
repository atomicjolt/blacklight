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
