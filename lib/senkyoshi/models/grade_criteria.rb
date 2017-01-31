require "senkyoshi/models/rule_criteria"
module Senkyoshi
  class GradeCriteria < RuleCriteria
    attr_reader(:outcome_def_id)

    def initialize(id, outcome_def_id, negated)
      super(id, negated)
      @outcome_def_id = outcome_def_id
      @foreign_content_id = nil
    end

    def get_foreign_id
      @foreign_asidata_id || @foreign_content_id
    end

    def self.get_outcome_def_id(xml)
      xml.xpath("./OUTCOME_DEFINITION_ID/@value").text
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = Senkyoshi.true? RuleCriteria.get_negated xml
      outcome_def_id = GradeCriteria.get_outcome_def_id xml
      new(id, outcome_def_id, negated)
    end

    ##
    # use gradebook to match outcome_definition_id to the
    # assignment content id
    ##
    def set_foreign_ids(resources, outcome_def_id)
      gradebook = resources.find_instances_of(Gradebook).first

      outcome = gradebook.find_outcome_def(outcome_def_id)
      if outcome
        @foreign_content_id = outcome.content_id
        @foreign_asidata_id = outcome.asidataid
      end
    end

    def canvas_conversion(course, content_id, resources)
      set_foreign_ids(resources, @outcome_def_id)
      super(course, content_id, resources)
    end
  end
end
