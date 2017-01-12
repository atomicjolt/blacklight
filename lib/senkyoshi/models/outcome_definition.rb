require "senkyoshi/models/resource"
require "senkyoshi/models/assignment_group"

require "byebug"
module Senkyoshi
  class OutcomeDefinition < Resource
    attr_reader :content_id, :asidataid, :is_user_created
    def self.from(xml, category)
      outcome_definition = OutcomeDefinition.new(category)
      outcome_definition.iterate_xml(xml)
    end

    def initialize(category)
      @category = category
    end

    def iterate_xml(xml)
      @content_id = xml.xpath("./CONTENTID/@value").text
      @asidataid = xml.xpath("./ASIDATAID/@value").text
      @id = xml.xpath("./@id").text
      @title = xml.xpath("./TITLE/@value").text
      @points_possible = xml.xpath("./POINTSPOSSIBLE/@value").text
      @is_user_created = xml.xpath("./ISUSERCREATED/@value").text == "true"
      self
    end

    ##
    # Determine if an outcome definition is linked to any 'CONTENT' or
    # assignments
    ##
    def self.orphan?(outcome_def)
      outcome_def.content_id.empty? &&
        outcome_def.asidataid.empty? &&
        outcome_def.is_user_created
    end

    def canvas_conversion(course, _)
      assignment_group = course.assignment_groups.
        detect { |a| a.title == @category }
      unless assignment_group
        assignment_group = AssignmentGroup.create_assignment_group(@category)
        course.assignment_groups << assignment_group
      end

      # Create an assignment
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = Senkyoshi.create_random_hex
      assignment.assignment_group_identifier_ref = assignment_group.identifier
      assignment.title = @title
      assignment.position = 1
      assignment.points_possible = @points_possible
      assignment.workflow_state = "published"
      assignment.grading_type = "points"

      course.assignments << assignment
      course
    end
  end
end
