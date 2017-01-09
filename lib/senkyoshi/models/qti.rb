require "senkyoshi/models/assignment_group"
require "senkyoshi/models/assignment"
require "senkyoshi/models/question"
require "senkyoshi/models/resource"

QTI_TYPE = {
  "Test" => "Assessment",
  "Survey" => "Survey",
  "Pool" => "QuestionBank",
}.freeze

module Senkyoshi
  class QTI < Resource
    def self.from(data, pre_data)
      type = data.at("bbmd_assessmenttype").text
      qti_class = Senkyoshi.const_get QTI_TYPE[type]
      qti = qti_class.new
      qti.iterate_xml(data, pre_data)
    end

    def initialize
      @title = ""
      @description = ""
      @quiz_type = ""
      @points_possible = 0
      @items = []
      @group_name = ""
      @workflow_state = "published"
      @available = true
    end

    def iterate_xml(data, pre_data)
      @group_name = data.at("bbmd_assessmenttype").text
      @id = pre_data[:assignment_id] || pre_data[:file_name]
      @title = data.at("assessment").attributes["title"].value
      @points_possible = data.at("qmd_absolutescore_max").text

      description = data.at("presentation_material").
        at("mat_formattedtext").text
      instructions = data.at("rubric").
        at("mat_formattedtext").text
      @description = %{
        #{description}
        #{instructions}
      }
      @items = data.search("item").to_a
      @items += get_quiz_pool_items(data.search("selection_ordering"))
      self
    end

    def get_quiz_pool_items(selection_order)
      selection_order.flat_map do |selection|
        selection_number = selection.at("selection_number").text
        if selection.at("sourcebank_ref")
          sourcebank_ref = selection.at("sourcebank_ref").text
          {
            file_name: sourcebank_ref,
            selection_number: selection_number,
          }
        elsif selection.at("or_selection")
          items = selection.search("selection_metadata").to_a
          items.sample(selection_number.to_i).flat_map do |metadata|
            {
              question_id: metadata.text,
            }
          end
        end
      end
    end

    def canvas_conversion(course, resources)
      assessment = CanvasCc::CanvasCC::Models::Assessment.new
      assessment.identifier = @id
      course = create_assignment_group(course, resources)
      assignment = create_assignment
      assignment.quiz_identifier_ref = assessment.identifier
      course.assignments << assignment
      assessment = setup_assessment(assessment, assignment, resources)
      assessment = create_items(course, assessment, resources)
      course.assessments << assessment
      course
    end

    def setup_assessment(assessment, assignment, resources)
      assessment.title = @title
      assessment.description = fix_html(@description, resources)
      if @items.count.zero?
        assessment.description +=
          "Empty Quiz -- No questions were contained in the blackboard quiz"
      end
      assessment.available = @available
      assessment.quiz_type = @quiz_type
      assessment.points_possible = @points_possible
      assessment.assignment = assignment
      assessment
    end

    def create_items(course, assessment, resources)
      @items = @items - ["", nil]
      question_ids = @items.map { |i| i[:question_id] } - [nil]
      questions = @items.flat_map do |item|
        if !item[:question_id] && !item[:file_name]
          Question.from(item)
        else
          get_quiz_pool_questions(course, item, question_ids)
        end
      end
      assessment.items = []
      questions.each do |item|
        if canvas_module?(item)
          assessment.items << item
        else
          assessment.items << item.canvas_conversion(assessment, resources)
        end
      end
      assessment
    end

    def canvas_module?(item)
      item.class.to_s.include?("CanvasCc::CanvasCC::Models")
    end

    def get_quiz_pool_questions(course, item, question_ids)
      if item[:file_name]
        question_bank = course.question_banks.
          detect { |qb| qb.identifier == item[:file_name] }
        filtered_questions = question_bank.questions.
          reject { |q| question_ids.include?(q.original_identifier) }
        filtered_questions.sample(item[:selection_number].to_i)
      elsif item[:question_id]
        questions = course.question_banks.flat_map(&:questions)
        questions.detect { |q| q.original_identifier == item[:question_id] }
      end
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