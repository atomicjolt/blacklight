require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "OpinionScale" do
    before do
      @opinion_scale = OpinionScale.new
    end

    describe "initialize" do
      it "should initialize opinion_scale" do
        assert_equal (@opinion_scale.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal answers.count, 6
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text),
                     "<p>Strongly Agree</p>"
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 0.0
      end
    end
  end
end
