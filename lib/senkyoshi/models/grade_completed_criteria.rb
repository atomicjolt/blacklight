require "senkyoshi/models/rule_criteria"
module Senkyoshi
  class GradeCompletedCriteria < RuleCriteria
    attr_reader(:outcome_def_id)

    def initialize(id, outcome_def_id, negated)
      super(id, negated)
      @outcome_def_id = outcome_def_id
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = true? RuleCriteria.get_negated xml
      outcome_def_id = xml.xpath("./OUTCOME_DEFINITION_ID/@value").text
      GradeCompletedCriteria.new(id, outcome_def_id, negated)
    end
  end
end
