require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

include Senkyoshi

describe Senkyoshi do
  describe "QuestionBank" do
    before do
      xml = get_fixture_xml "question_bank.xml"
      pre_data = {}
      @question_bank = QTI.from(xml.children.first, pre_data)
      @resources = Senkyoshi::Collection.new
    end

    describe "initialize" do
      it "should initialize question_bank" do
        assert_equal (@question_bank.is_a? Senkyoshi::QuestionBank), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml" do
        title = "Just a test"
        points_possible = "120.0"
        group_name = "Pool"
        quiz_type = ""
        description = "<p>Do this test with honor</p>"
        instructions = "<p>Don't forget your virtue</p>"

        assert_equal (@question_bank.instance_variable_get :@title), title
        assert_equal (@question_bank.
          instance_variable_get :@quiz_type), quiz_type
        assert_equal (@question_bank.
          instance_variable_get :@points_possible), points_possible
        assert_equal (@question_bank.
          instance_variable_get :@group_name), group_name
        assert_equal (@question_bank.instance_variable_get :@items).count, 12

        actual_description = @question_bank.instance_variable_get :@description
        assert_includes actual_description, description
        assert_includes actual_description, instructions
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas question_bank" do
        course = CanvasCc::CanvasCC::Models::Course.new
        @question_bank.canvas_conversion(course, @resources)
        assert_equal course.question_banks.count, 1
      end
    end

    describe "setup_question_bank" do
      it "should return question_bank with details" do
        question_bank = CanvasCc::CanvasCC::Models::QuestionBank.new

        question_bank = @question_bank.
          setup_question_bank(question_bank, @resources)
        assert_equal question_bank.questions.count, 12
      end
    end

    describe "create_items" do
      it "should create items" do
        question_bank = CanvasCc::CanvasCC::Models::QuestionBank.new

        question_bank = @question_bank.create_items(question_bank, @resources)
        assert_equal question_bank.questions.count, 12
      end
    end
  end
end
