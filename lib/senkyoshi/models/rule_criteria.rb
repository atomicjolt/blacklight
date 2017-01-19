require "senkyoshi"

module Senkyoshi
  class RuleCriteria
    include Senkyoshi
    attr_reader(:id, :negated)

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

    def canvas_conversion(course, _resources)
      course
    end
  end
end
