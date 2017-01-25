require "senkyoshi/models/rule_criteria"
module Senkyoshi
  class GradeCompletedCriteria < RuleCriteria
    attr_reader(:outcome_def_id)

    def initialize(id, outcome_def_id, negated)
      super(id, negated)
      @outcome_def_id = outcome_def_id
      @content_id = nil
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = Senkyoshi.true? RuleCriteria.get_negated xml
      outcome_def_id = xml.xpath("./OUTCOME_DEFINITION_ID/@value").text
      GradeCompletedCriteria.new(id, outcome_def_id, negated)
    end

    def get_foreign_id
      @content_id
    end

    def get_completion_type
      COMPLETION_TYPES[:must_submit]
    end

    def get_content_id(gradebook)
      outcome = gradebook.find_outcome_def(@outcome_def_id)
      outcome.content_id if outcome
    end

    def canvas_conversion(course, content_id, resources)
      # use gradebook to match outcome_definition_id to the
      # assignment content id
      gradebook = resources.find_instances_of(Gradebook).first
      @content_id = get_content_id(gradebook) if gradebook

      super(course, content_id, resources)
    end
  end
end
