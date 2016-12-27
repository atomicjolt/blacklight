require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

include Senkyoshi

describe Senkyoshi do
  describe "Question" do
    before do
      @question = Question.new
      @resources = Senkyoshi::Collection.new
    end

    describe "initialize" do
      it "should initialize question" do
        assert_equal (@question.is_a? Object), true
      end

      it "should initialize with parameters" do
        assert_equal (@question.instance_variable_get :@max_score), 1
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml" do
        xml = get_fixture_xml "either_or.xml"
        @question = @question.iterate_xml(xml.children.first)

        original_identifier = "_46854313_1"
        blackboard_type = "Either/Or"
        question_type = "multiple_choice_question"
        points_possible = "10.0"
        title = "Question 3"
        correct = "<p>You did the right thing</p>"
        incorrect = "<p>Try again</p>"
        material = "<p>Whatever you want</p>"

        assert_equal (@question.
          instance_variable_get :@original_identifier), original_identifier
        assert_equal (@question.
          instance_variable_get :@blackboard_type), blackboard_type
        assert_equal (@question.
          instance_variable_get :@question_type), question_type
        assert_equal (@question.
          instance_variable_get :@points_possible), points_possible
        assert_equal (@question.instance_variable_get :@title), title
        assert_equal (@question.
          instance_variable_get :@general_correct_feedback), correct
        assert_equal (@question.
          instance_variable_get :@general_incorrect_feedback), incorrect
        assert_equal (@question.instance_variable_get :@material), material
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas question" do
        xml = get_fixture_xml "either_or.xml"
        @question = @question.iterate_xml(xml.children.first)

        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment.items = []
        @question.canvas_conversion(assessment, @resources)
        assert_equal assessment.items.count, 1
      end

      it "should create a canvas question with details and no answers" do
        title = "Question 3"
        xml = get_fixture_xml "either_or.xml"
        @question = @question.iterate_xml(xml.children.first)

        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment.items = []
        @question.canvas_conversion(assessment, @resources)
        assert_equal assessment.items.first.title, title
        assert_equal assessment.items.first.answers.count, 0
      end
    end

    describe "from" do
      it "should create a canvas question with correct details and answers" do
        xml = get_fixture_xml "either_or.xml"
        question = Question.from(xml.children.first)

        assessment = CanvasCc::CanvasCC::Models::Assessment.new
        assessment.items = []
        question.canvas_conversion(assessment, @resources)
        assert_equal assessment.items.first.answers.count, 2
      end
    end

    describe "get_fraction / set_answers" do
      it "should set the answer fraction to 0" do
        xml = get_fixture_xml "either_or.xml"
        resprocessing = xml.search("resprocessing")
        @question.set_answers(resprocessing)
        assert_equal @question.get_fraction("yes"), 0
      end

      it "should set the answer fraction to 10" do
        xml = get_fixture_xml "either_or.xml"
        resprocessing = xml.search("resprocessing")
        @question.set_answers(resprocessing)
        assert_equal @question.get_fraction("yes_no.true"), 1.0
      end
    end

    describe "set_feedback" do
      it "should send back correct feeback" do
        xml = get_fixture_xml "either_or.xml"
        correct_feedback = @question.set_feedback(xml, "correct")
        assert_equal correct_feedback, "<p>You did the right thing</p>"
      end

      it "should not send back correct feeback" do
        xml = get_fixture_xml "opinion.xml"
        correct_feedback = @question.set_feedback(xml, "correct")
        assert_equal correct_feedback, ""
      end
    end

    describe "set_feedback" do
      it "should send back incorrect feeback" do
        xml = get_fixture_xml "either_or.xml"
        incorrect_feedback = @question.set_feedback(xml, "incorrect")
        assert_equal incorrect_feedback, "<p>Try again</p>"
      end

      it "should not send back correct feeback" do
        xml = get_fixture_xml "opinion.xml"
        incorrect_feedback = @question.set_feedback(xml, "incorrect")
        assert_equal incorrect_feedback, ""
      end
    end

    describe "set_material" do
      it "should send back question material" do
        xml = get_fixture_xml "either_or.xml"
        material = @question.set_material(xml)
        assert_equal material, "<p>Whatever you want</p>"
      end

      it "should send back question material" do
        xml = get_fixture_xml "opinion.xml"
        material = @question.set_material(xml)
        assert_equal material, "<p>Do or die</p>"
      end
    end

    describe "set_max_score" do
      it "should send back max score" do
        xml = get_fixture_xml "either_or.xml"
        resprocessing = xml.search("resprocessing")
        assert_equal @question.set_max_score(resprocessing), "10.0"
      end

      it "should send back max score" do
        xml = get_fixture_xml "opinion.xml"
        resprocessing = xml.search("resprocessing")
        assert_equal @question.set_max_score(resprocessing), "0.0"
      end
    end
  end
end
