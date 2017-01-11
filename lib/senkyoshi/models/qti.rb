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
      @group_name = pre_data[:category] || data.at("bbmd_assessmenttype").text
      @id = pre_data[:assignment_id] || pre_data[:file_name]
      @title = data.at("assessment").attributes["title"].value
      @points_possible = data.at("qmd_absolutescore_max").text
      set_assessment_details(pre_data)
      @due_at = pre_data[:due_at]

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

    def set_assessment_details(pre_data)
      @time_limit = pre_data[:time_limit]
      @allowed_attempts = pre_data[:allowed_attempts]
      @allowed_attempts = -1 if pre_data[:unlimited_attempts] == "true"
      @cant_go_back = pre_data[:cant_go_back]
      @show_correct_answers = pre_data[:show_correct_answers]
      if pre_data[:access_code] && !pre_data[:access_code].empty?
        @access_code = pre_data[:access_code]
      end
      if pre_data[:one_question_at_a_time] == "QUESTION_BY_QUESTION"
        @one_question_at_a_time = "true"
      else
        @one_question_at_a_time = "false"
      end
    end

    def get_quiz_pool_items(selection_order)
      selection_order.flat_map do |selection|
        weight = selection.previous.at("qmd_weighting").text
        selection_number = selection.at("selection_number").text
        item = {
          weight: weight,
          selection_number: selection_number,
        }
        if selection.at("sourcebank_ref")
          sourcebank_ref = selection.at("sourcebank_ref").text
          item[:file_name] = sourcebank_ref
        elsif selection.at("or_selection")
          questions = selection.search("selection_metadata").map(&:text)
          item[:questions] = questions
        end
        item
      end
    end

    def get_pre_data(xml, _)
      {
        original_file_name: xml.xpath("/COURSEASSESSMENT/
          ASMTID/@value").first.text,
        one_question_at_a_time: xml.xpath("/COURSEASSESSMENT/
          DELIVERYTYPE/@value").first.text,
        time_limit: xml.xpath("/COURSEASSESSMENT/
          TIMELIMIT/@value").first.text,
        access_code: xml.xpath("/COURSEASSESSMENT/
          PASSWORD/@value").first.text,
        allowed_attempts: xml.xpath("/COURSEASSESSMENT/
          ATTEMPTCOUNT/@value").first.text,
        unlimited_attempts: xml.xpath("/COURSEASSESSMENT/
          FLAGS/ISUNLIMITEDATTEMPTS/@value").first.text,
        cant_go_back: xml.xpath("/COURSEASSESSMENT/
          FLAGS/ISBACKTRACKPROHIBITED/@value").first.text,
        show_correct_answers: xml.xpath("/COURSEASSESSMENT/
          FLAGS/SHOWCORRECTANSWER/@value").first.text,
      }
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
      assessment.time_limit = @time_limit
      assessment.access_code = @access_code
      assessment.allowed_attempts = @allowed_attempts
      assessment.cant_go_back = @cant_go_back
      assessment.show_correct_answers = @show_correct_answers
      assessment.one_question_at_a_time = @one_question_at_a_time
      if @due_at && !@due_at.empty?
        assessment.due_at = Time.strptime(@due_at, "%Y-%m-%d %H:%M:%S %z")
      end
      assessment.assignment = assignment
      assessment
    end

    def create_items(course, assessment, resources)
      questions = get_questions(course)
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

    def get_questions(course)
      @items = @items - ["", nil]
      @items.flat_map do |item|
        if !item[:selection_number]
          Question.from(item)
        else
          get_question_group(course, item)
        end
      end
    end

    def canvas_module?(item)
      item.is_a? CanvasCc::CanvasCC::Models::QuestionGroup
    end

    def get_question_group(course, item)
      if item[:questions]
        questions = course.question_banks.flat_map(&:questions)
        canvas_questions = item[:questions].flat_map do |question|
          questions.detect { |q| q.original_identifier == question }
        end.compact
      end
      question_group = CanvasCc::CanvasCC::Models::QuestionGroup.new
      question_group.identifier = Senkyoshi.create_random_hex
      question_group.title = "Question Group"
      question_group.selection_number = item[:selection_number]
      question_group.questions = canvas_questions || []
      question_group.sourcebank_ref = item[:file_name]
      question_group.points_per_item = item[:weight]
      question_group
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
