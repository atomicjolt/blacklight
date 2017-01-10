require "byebug"
module Senkyoshi
  class OutcomeDefinition
    def initialize(id, content_id)
      @id = id
      @content_id = content_id
    end

    def canvas_conversion(course, _)
      # Create an assignment
      course
    end

    def self.from_xml(xml)
      content_id = xml.xpath("./CONTENTID/@value").text
      id = xml.xpath("./@id").text
      OutcomeDefinition.new(id, content_id)
    end
  end
end
