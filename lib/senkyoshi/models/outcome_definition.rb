require "byebug"
module Senkyoshi
  class OutcomeDefinition
    attr_reader(:id, :content_id, :title, :points_possible)

    def initialize(id, content_id, title, points_possible)
      @id = id
      @content_id = content_id
      @title = title
      @points_possible = points_possible
    end

    def canvas_conversion(course, _)
      # Create an assignment
      assignment = CanvasCc::CanvasCC::Models::Assignment.new

      course.assignments << assignment
      course
    end

    def self.from_xml(xml)
      content_id = xml.xpath("./CONTENTID/@value").text
      id = xml.xpath("./@id").text
      OutcomeDefinition.new(id, content_id, nil, nil)
    end
  end
end
