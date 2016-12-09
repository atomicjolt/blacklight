require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "MultipleChoice" do
    before do
      @multiple_choice = MultipleChoice.new
    end

    describe "initialize" do
      it "should initialize multiple_choice" do
        assert_equal (@multiple_choice.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal answers.count, 4
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text),
                     "<p>I am just kidding</p>"
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 0.0
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers[1].instance_variable_get :@fraction), 1.0
      end
    end
  end
end
