require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

include Senkyoshi

describe Senkyoshi do
  describe "Assessment" do
    before do
      xml = get_fixture_xml "assessment.xml"
      pre_data = {}
      @assessment = QTI.from(xml.children.first, pre_data)
      @resources = Senkyoshi::Collection.new
    end

    describe "initialize" do
      it "should initialize assessment" do
        assert_equal (@assessment.is_a? Senkyoshi::Assessment), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml" do
        title = "Just a test"
        points_possible = "120.0"
        group_name = "Test"
        quiz_type = "assignment"
        description = "<p>Do this test with honor</p>"
        instructions = "<p>Don't forget your virtue</p>"

        assert_equal (@assessment.instance_variable_get :@title), title
        assert_equal (@assessment.instance_variable_get :@quiz_type), quiz_type
        assert_equal (@assessment.
          instance_variable_get :@points_possible), points_possible
        assert_equal (@assessment.
          instance_variable_get :@group_name), group_name
        assert_equal (@assessment.instance_variable_get :@items).count, 12

        actual_description = @assessment.instance_variable_get :@description
        assert_includes actual_description, description
        assert_includes actual_description, instructions
      end

      it "should iterate through xml and has category pre_data" do
        xml = get_fixture_xml "assessment.xml"
        group_name = "Survey"
        pre_data = { category: group_name }
        @assessment = QTI.from(xml.children.first, pre_data)
        @resources = Senkyoshi::Collection.new
        assert_equal (@assessment.
          instance_variable_get :@group_name), group_name
      end
    end

    describe "set_assessment_details" do
      before do
        @time_limit = 10
        @true_value = "true"
        @false_value = "false"
        @question_at_a_time = "QUESTION_BY_QUESTION"
        @pre_data = {
          time_limit: @time_limit,
          allowed_attempts: "",
          unlimited_attempts: @true_value,
          cant_go_back: @true_value,
          show_correct_answers: @false_value,
          one_question_at_a_time: @question_at_a_time,
        }
      end

      it "should set the values from the pre_data" do
        @assessment.set_assessment_details(@pre_data)

        assert_equal (@assessment.
          instance_variable_get :@time_limit), @time_limit
        assert_equal (@assessment.
          instance_variable_get :@cant_go_back), @true_value
        assert_equal (@assessment.
          instance_variable_get :@show_correct_answers), @false_value
        assert_equal (@assessment.
          instance_variable_get :@one_question_at_a_time), @true_value
      end

      it "should set the values from the pre_data allowed_attempts number" do
        allowed_attempts = "5"
        @pre_data[:allowed_attempts] = allowed_attempts
        @pre_data[:unlimited_attempts] = @false_value
        @assessment.set_assessment_details(@pre_data)
        assert_equal (@assessment.
          instance_variable_get :@allowed_attempts), allowed_attempts
      end

      it "should set the values from the pre_data allowed_attempts infinite" do
        @assessment.set_assessment_details(@pre_data)
        assert_equal (@assessment.
          instance_variable_get :@allowed_attempts), -1
      end

      it "should set the values from the pre_data access_code present" do
        access_code = "123456"
        @pre_data[:access_code] = access_code
        @assessment.set_assessment_details(@pre_data)
        assert_equal (@assessment.
          instance_variable_get :@access_code), access_code
      end

      it "should set the values from the pre_data access_code not present" do
        @pre_data[:access_code] = ""
        @assessment.set_assessment_details(@pre_data)
        assert_nil (@assessment.instance_variable_get :@access_code)
      end

      it "should set the values from the pre_data one_question_at_a_time" do
        one_question_at_a_time = "QUESTION_BY_QUESTION"
        @pre_data[:one_question_at_a_time] = one_question_at_a_time
        @assessment.set_assessment_details(@pre_data)
        assert_equal (@assessment.
          instance_variable_get :@one_question_at_a_time), @true_value
      end

      it "should set pre_data one_question_at_a_time false" do
        @pre_data[:one_question_at_a_time] = ""
        @assessment.set_assessment_details(@pre_data)
        assert_equal (@assessment.
          instance_variable_get :@one_question_at_a_time), @false_value
      end
    end

    describe "get_quiz_pool_items" do
      it "should return an array of quiz items" do
        xml = get_fixture_xml "qti_pool.xml"
        pre_data = {}
        qti_pool = QTI.from(xml.children.first, pre_data)

        selection_order = xml.search("selection_ordering")
        items = qti_pool.get_quiz_pool_items(selection_order)
        assert_equal (items.map { |i| i[:questions] } - [nil]).count, 1
        assert_equal (items.map { |i| i[:file_name] } - [nil]).count, 1
        assert_equal items.count, 2
      end
    end

    describe "get_pre_data" do
      it "should set the values in the pre_data" do
        xml = get_fixture_xml "course_assessment.xml"
        results = @assessment.get_pre_data(xml, {})

        assert_equal results[:original_file_name], "res00048"
        assert_equal results[:time_limit], "20"
        assert_equal results[:allowed_attempts], ""
        assert_equal results[:unlimited_attempts], "false"
        assert_equal results[:cant_go_back], "true"
        assert_equal results[:show_correct_answers], "false"
        assert_equal results[:access_code], ""
        assert_equal results[:one_question_at_a_time], "ALL_AT_ONCE"
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas assessment" do
        course = CanvasCc::CanvasCC::Models::Course.new
        @assessment.canvas_conversion(course, @resources)
        assert_equal course.assessments.count, 1
      end
    end

    describe "setup_assessment" do
      it "should return assessment with details" do
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        title = "Just a test"
        description = "<p>Do this test with honor</p>"
        instructions = "<p>Don't forget your virtue</p>"

        assignment = @assessment.create_assignment
        assessment =
          @assessment.setup_assessment(assessment, assignment, @resources)
        assert_equal assessment.title, title
        assert_includes assessment.description, description
        assert_includes assessment.description, instructions
      end

      it "should return assessment with a description of an empty quiz" do
        xml = get_fixture_xml "empty_quiz.xml"
        pre_data = {}
        empty_quiz = QTI.from(xml.children.first, pre_data)
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        assignment = empty_quiz.create_assignment
        assessment =
          empty_quiz.setup_assessment(assessment, assignment, @resources)
        assert_equal (empty_quiz.instance_variable_get :@items).count, 0
        assert_includes assessment.description, "Empty Quiz"
      end
    end

    describe "create_items" do
      it "should create items" do
        course = CanvasCc::CanvasCC::Models::Course.new
        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment = @assessment.create_items(course, assessment, @resources)
        assert_equal assessment.items.count, 12
      end

      it "should create qti_pool items" do
        course = CanvasCc::CanvasCC::Models::Course.new
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        quiz_bank_xml = get_fixture_xml "question_bank.xml"
        pre_data = { file_name: "res00039" }
        quiz_bank = QTI.from(quiz_bank_xml.children.first, pre_data)
        course = quiz_bank.canvas_conversion(course, @resources)

        pool_xml = get_fixture_xml "qti_pool.xml"
        pool_pre_data = {}
        qti_pool = QTI.from(pool_xml.children.first, pool_pre_data)

        assessment = qti_pool.create_items(course, assessment, @resources)
        assert_equal assessment.items.count, 2
      end
    end

    describe "canvas_module?" do
      it "should return true" do
        question_group = CanvasCc::CanvasCC::Models::QuestionGroup.new
        assert_equal @assessment.canvas_module?(question_group), true
      end

      it "should return false" do
        assert_equal @assessment.canvas_module?(@assessment), false
      end
    end

    describe "get_question_group" do
      it "should return the array with the correct questions" do
        course = CanvasCc::CanvasCC::Models::Course.new

        quiz_bank_xml = get_fixture_xml "question_bank.xml"
        pre_data = { file_name: "res00039" }
        quiz_bank = QTI.from(quiz_bank_xml.children.first, pre_data)
        course = quiz_bank.canvas_conversion(course, @resources)

        pool_xml = get_fixture_xml "qti_pool.xml"
        pool_pre_data = {}
        qti_pool = QTI.from(pool_xml.children.first, pool_pre_data)

        selection_order = pool_xml.search("selection_ordering")
        items = qti_pool.get_quiz_pool_items(selection_order)

        item = items.detect { |i| i[:questions] }

        question_group = qti_pool.
          get_question_group(course, item)

        assert_equal question_group.questions.count, 2
        assert_equal question_group.selection_number.to_i, 2
        assert_nil question_group.sourcebank_ref
      end

      it "should return the array with the correct questions" do
        course = CanvasCc::CanvasCC::Models::Course.new

        quiz_bank_xml = get_fixture_xml "question_bank.xml"
        pre_data = { file_name: "res00039" }
        quiz_bank = QTI.from(quiz_bank_xml.children.first, pre_data)
        course = quiz_bank.canvas_conversion(course, @resources)

        pool_xml = get_fixture_xml "qti_pool.xml"
        pool_pre_data = {}
        qti_pool = QTI.from(pool_xml.children.first, pool_pre_data)

        selection_order = pool_xml.search("selection_ordering")
        items = qti_pool.get_quiz_pool_items(selection_order)

        item = items.detect { |i| i[:file_name] == "res00039" }

        question_group = qti_pool.
          get_question_group(course, item)

        assert_equal question_group.questions.count, 0
        assert_equal question_group.selection_number.to_i, 5
        assert_equal question_group.sourcebank_ref, "res00039"
      end
    end

    describe "create_assignment_group" do
      it "should create assignment groups in course" do
        course = CanvasCc::CanvasCC::Models::Course.new

        course = @assessment.create_assignment_group(course, @resources)
        assert_equal course.assignment_groups.count, 1
      end
    end

    describe "create_assignment" do
      it "should create an assignment" do
        quiz_type = "assignment"

        assignment = @assessment.create_assignment
        assert_equal assignment.title,
                     (@assessment.instance_variable_get :@title)
        assert_equal (@assessment.instance_variable_get :@quiz_type), quiz_type
        assert_equal assignment.assignment_group_identifier_ref,
                     (@assessment.instance_variable_get :@group_id)
        assert_equal assignment.workflow_state,
                     (@assessment.instance_variable_get :@workflow_state)
        assert_equal assignment.points_possible,
                     (@assessment.instance_variable_get :@points_possible)
        assert_equal assignment.position, 1
        assert_equal assignment.grading_type, "points"
        assert_equal assignment.submission_types, ["online_quiz"]
      end
    end
  end
end
