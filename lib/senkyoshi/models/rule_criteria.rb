require "senkyoshi"

module Senkyoshi
  class RuleCriteria
    include Senkyoshi
    attr_reader(:id, :negated)

    COMPLETION_TYPES = {
      must_view: "must_view",
      must_submit: "must_submit",
      min_score: "min_score",
      must_contribute: "must_contribute",
    }.freeze

    def initialize(id, negated)
      @id = id
      @negated = negated
    end

    def self.get_id(xml)
      xml.xpath("./@id").text
    end

    def self.get_negated(xml)
      xml.xpath("./NEGATED/@value").text
    end

    def self.from_xml(_xml); end

    def self.in_same_module?(modules, content_id, resource_id)
      content_module = Module.find_module_from_item_id(modules, content_id)
      resource_module = Module.find_module_from_item_id(modules, resource_id)
      !content_module.nil? && content_module == resource_module
    end

    def self.module_prerequisite?(modules, content_id, resource_id)
      !in_same_module? modules, content_id, resource_id
    end

    def self.module_completion_requirement?(modules, content_id, resource_id)
      in_same_module? modules, content_id, resource_id
    end

    def canvas_conversion(course, _resources)
      course
    end
  end
end
