require "senkyoshi/models/grade_completed_criteria"
require "senkyoshi/models/content_reviewed_criteria"
require "senkyoshi/models/date_range_criteria"
require "senkyoshi/models/grade_range_criteria"
require "senkyoshi/models/grade_range_percent_criteria"
require "senkyoshi/models/resource"

module Senkyoshi
  class Rule < Resource
    attr_reader(:title, :content_id, :criteria_list, :id)

    CRITERIA_MAP = {
      grade_completed_criteria: GradeCompletedCriteria,
      content_reviewed_criteria: ContentReviewedCriteria,
      date_range_criteria: DateRangeCriteria,
      grade_range_criteria: GradeRangeCriteria,
      grade_range_percent_criteria: GradeRangePercentCriteria,
    }.freeze

    def initialize
      @criteria_list = []
    end

    def get_criteria_list(xml)
      xml.children.select { |child_xml| !child_xml.blank? }.
        map do |child_xml|
          CRITERIA_MAP[child_xml.name.downcase.to_sym].from_xml(child_xml)
        end
    end

    def iterate_xml(xml, _ = nil)
      @title = xml.xpath("./TITLE/@value").text
      @content_id = xml.xpath("./CONTENT_ID/@value").text
      @id = xml.xpath("./@id").text
      @criteria_list = get_criteria_list(xml.xpath("./CRITERIA_LIST"))
      self
    end

    def canvas_conversion(course, _resources)
      course
    end
  end
end
