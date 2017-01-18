require "senkyoshi/models/rule_criteria"

module Senkyoshi
  class ContentReviewedCriteria < RuleCriteria
    attr_reader(:reviewed_content_id)

    def initialize(id, reviewed_content_id, negated)
      super(id, negated)
      @reviewed_content_id = reviewed_content_id
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = true? RuleCriteria.get_negated xml
      outcome_def_id = xml.xpath("./REVIEWED_CONTENT_ID/@value").text
      ContentReviewedCriteria.new(id, outcome_def_id, negated)
    end
  end
end
