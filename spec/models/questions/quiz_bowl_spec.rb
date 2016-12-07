require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "QuizBowl" do
    before do
      @quiz_bowl = QuizBowl.new
    end

    describe "initialize" do
      it "should initialize quiz_bowl" do
        assert_equal (@quiz_bowl.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "quiz_bowl.xml"
        @quiz_bowl = @quiz_bowl.iterate_xml(xml.children.first)

        assert_includes (@quiz_bowl.instance_variable_get :@material),
                        (@quiz_bowl.instance_variable_get :@title)
        assert_includes (@quiz_bowl.instance_variable_get :@material),
                        "This question was imported from"
        assert_includes (@quiz_bowl.instance_variable_get :@material),
                        "an external source. It was a Quiz Bowl question,"
        assert_includes (@quiz_bowl.instance_variable_get :@material),
                        "which is not supported in this quiz tool."
      end
    end
  end
end
