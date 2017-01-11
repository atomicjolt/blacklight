require "byebug"
module Senkyoshi
  class OutcomeDefinition
    attr_reader :content_id

    def initialize(category)
      @category = category
      @points_possible = 0
      @workflow_state = "published"
    end

    def iterate_xml(xml)
      @content_id = xml.xpath("./CONTENTID/@value").text
      @id = xml.xpath("./@id").text
      @title = xml.xpath("./TITLE/@value").text
      @points_possible = xml.xpath("./POINTSPOSSIBLE/@value").text
      self
    end

    def canvas_conversion(course, _)
      course = create_assignment_group(course)

      # Create an assignment
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = Senkyoshi.create_random_hex
      assignment.assignment_group_identifier_ref = @group_id
      # assignment.submission_types << "online_quiz"
      assignment.title = @title
      assignment.position = 1
      assignment.points_possible = @points_possible
      assignment.workflow_state = @workflow_state
      assignment.grading_type = "points"

      course.assignments << assignment
      course
    end

    def create_assignment_group(course)
      group = course.assignment_groups.detect { |a| a.title == @group_name }
      if group
        @group_id = group.identifier
      else
        @group_id = Senkyoshi.create_random_hex
        assignment_group = AssignmentGroup.new(@group_name, @group_id)
        course = assignment_group.canvas_conversion(course, nil)
      end
      course
    end

    def self.from_xml(xml, category)
      outcome_definition = OutcomeDefinition.new(category)
      outcome_definition.iterate_xml(xml)
    end
  end
end
