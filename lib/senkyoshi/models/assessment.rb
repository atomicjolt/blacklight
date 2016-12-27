require "senkyoshi/models/assignment_group"
require "senkyoshi/models/assignment"
require "senkyoshi/models/question"
require "senkyoshi/models/resource"

module Senkyoshi
  class Assessment < Resource
    def initialize
      @title = ""
      @description = ""
      @quiz_type = "assignment"
      @points_possible = 0
      @items = []
      @group_name = ""
      @workflow_state = "published"
      @available = true
    end

    def iterate_xml(data, pre_data)
      pre_data ||= {}
      @id = pre_data[:assignment_id] || Senkyoshi.create_random_hex
      @title = data.at("assessment").attributes["title"].value
      @points_possible = data.at("qmd_absolutescore_max").text
      @description = data.at("presentation_material").
        at("mat_formattedtext").text
      @group_name = data.at("bbmd_assessmenttype").text
      data.at("section").children.map do |item|
        @items.push(item) if item.name == "item"
      end
      self
    end

    def canvas_conversion(course, resources)
      if @items.count > 0
        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment.identifier = @id
        course = create_assignment_group(course, resources)
        assignment = create_assignment
        assignment.quiz_identifier_ref = assessment.identifier
        course.assignments << assignment
        assessment = setup_assessment(assessment, assignment, resources)
        course.assessments << assessment
      end
      course
    end

    def setup_assessment(assessment, assignment, resources)
      assessment.title = @title
      assessment.description = fix_html(@description, resources)
      assessment.available = @available
      assessment.quiz_type = @quiz_type
      assessment.points_possible = @points_possible
      assessment = create_items(assessment, resources)
      assessment.assignment = assignment
      assessment
    end

    def create_items(assessment, resources)
      @items = @items - ["", nil]
      questions = @items.map do |item|
        Question.from(item)
      end
      assessment.items = []
      questions.each do |item|
        assessment = item.canvas_conversion(assessment, resources)
      end
      assessment
    end

    def create_assignment_group(course, resources)
      group = course.assignment_groups.detect { |a| a.title == @group_name }
      if group
        @group_id = group.identifier
      else
        @group_id = Senkyoshi.create_random_hex
        assignment_group = AssignmentGroup.new(@group_name, @group_id)
        course = assignment_group.canvas_conversion(course, resources)
      end
      course
    end

    def create_assignment
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = Senkyoshi.create_random_hex
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
