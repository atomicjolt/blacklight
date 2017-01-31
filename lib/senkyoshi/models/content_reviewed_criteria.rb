require "senkyoshi/models/rule_criteria"

module Senkyoshi
  class ContentReviewedCriteria < RuleCriteria
    attr_reader(:reviewed_content_id)

    def initialize(id, negated, reviewed_content_id)
      super(id, negated)
      @reviewed_content_id = reviewed_content_id
    end

    def self.from_xml(xml)
      id = RuleCriteria.get_id xml
      negated = Senkyoshi.true? RuleCriteria.get_negated(xml)
      reviewed_content_id = xml.xpath("./REVIEWED_CONTENT_ID/@value").text
      ContentReviewedCriteria.new(id, negated, reviewed_content_id)
    end

    def get_foreign_id
      @reviewed_content_id
    end

    def get_completion_type
      COMPLETION_TYPES[:must_view]
    end
  end
end
