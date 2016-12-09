require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "FillInBlank" do
    before do
      @fill_in_blank = FillInBlank.new
    end

    describe "initialize" do
      it "should initialize fill_in_blank" do
        assert_equal (@fill_in_blank.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "fill_in_blank.xml"
        @fill_in_blank = @fill_in_blank.iterate_xml(xml.children.first)

        answers = @fill_in_blank.instance_variable_get :@answers
        assert_includes (answers.first.instance_variable_get :@answer_text),
                        "Hay"
      end

      it "should iterate and contain the right fraction" do
        xml = get_fixture_xml "fill_in_blank.xml"
        @fill_in_blank = @fill_in_blank.iterate_xml(xml.children.first)

        answers = @fill_in_blank.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction),
                     (@fill_in_blank.instance_variable_get :@max_score)
      end
    end
  end
end
