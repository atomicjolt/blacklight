require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "NumericalQuestion" do
    before do
      @numeric = NumericalQuestion.new
    end

    describe "initialize" do
      it "should initialize numeric" do
        assert_equal (@numeric.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.count, 1
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        tolerances = @numeric.instance_variable_get :@tolerances

        assert_equal tolerances, {}
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges
        answers = @numeric.instance_variable_get :@answers

        assert_equal answers.first.id, ranges.first.first
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.first.last.low_range, 137
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.first.last.high_range, 167
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        answers = @numeric.instance_variable_get :@answers
        max_score = @numeric.instance_variable_get :@max_score

        assert_equal answers.first.fraction, max_score
      end
    end
  end
end
