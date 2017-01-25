require "senkyoshi/models/grade_criteria"

module Senkyoshi
  class GradeRangePercentCriteria < GradeCriteria
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

    def get_foreign_id
      @asidata_id
    end

    def get_asi_data_id(gradebook)
      outcome = gradebook.find_outcome_def(@outcome_def_id)
      outcome.asidataid if outcome
    end

    def make_completion(mod)
      super(mod).tap do |completion_requirement|
        completion_requirement.min_score = @min_score
      end
    end

    def canvas_conversion(course, content_id, resources)
      gradebook = resources.find_instances_of(Gradebook).first
      @asidata_id = get_asi_data_id(gradebook) if gradebook
      super(course, content_id, resources)
    end
  end
end
