require "blacklight/models/assignment_group"
require "blacklight/models/assignment"
require "blacklight/models/question"

module Blacklight
  class Assessment
    def initialize
      @title = ""
      @description = ""
      @quiz_type = "assignment"
      @points_possible = 0
      @items = []
      @group_name
      @group_id
      @workflow_state = "published"
      @available = true
    end

    def iterate_xml(data)
      @title = data.children.at("assessment").attributes["title"].value
      @points_possible = data.children.at("qmd_absolutescore_max").text
      @description = data.children.at("presentation_material").
        children.at("mat_formattedtext").text
      @group_name = data.children.at("bbmd_assessmenttype").text
      data.children.at("section").children.map do |item|
        @items.push(item) if item.name == "item"
      end
      self
    end

    def canvas_conversion(course)
      if @items.count > 0
        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment.identifier = Blacklight.create_random_hex
        course = create_assignment_group(course)
        assignment = create_assignment
        assignment.quiz_identifier_ref = assessment.identifier
        course.assignments << assignment
        assessment = setup_assessment(assessment, assignment)
        course.assessments << assessment
      end
      course
    end

    def setup_assessment(assessment, assignment)
      assessment.title = @title
      assessment.description = @description
      assessment.available = @available
      assessment.quiz_type = @quiz_type
      assessment.points_possible = @points_possible
      assessment = create_items(assessment)
      assessment.assignment = assignment
      assessment
    end

    def create_items(assessment)
      items = []
      @items = @items - ["", nil]
      @items.each do |item|
        question = Question.from(item)
        items.push(question.iterate_xml(item))
      end
      assessment.items = []
      items.each do |item|
        assessment = item.canvas_conversion(assessment)
      end
      assessment
    end

    def create_assignment_group(course)
      group = course.assignment_groups.detect { |a| a.title == @group_name }
      if group == nil
        @group_id = Blacklight.create_random_hex
        assignment_group = AssignmentGroup.new(@group_name, @group_id)
        course = assignment_group.canvas_conversion(course)
      else
        @group_id = group.identifier
      end
      course
    end

    def create_assignment
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = Blacklight.create_random_hex
      assignment.assignment_group_identifier_ref = @group_id
      assignment.title = @title
      assignment.position = 1
      assignment.submission_types << "online_quiz"
      assignment.grading_type = "points"
      assignment.workflow_state = @workflow_state
      assignment.points_possible = @points_possible
      assignment
    end
  end
end
