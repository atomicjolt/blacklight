require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "FillInBlankPlus" do
    before do
      @fill_plus = FillInBlankPlus.new
    end

    describe "initialize" do
      it "should initialize fill_in_blank_plus" do
        assert_equal (@fill_plus.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "fill_in_blank_plus.xml"
        @fill_plus = @fill_plus.iterate_xml(xml.children.first)

        answers = @fill_plus.instance_variable_get :@answers
        assert_equal answers.count, 5
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "fill_in_blank_plus.xml"
        @fill_plus = @fill_plus.iterate_xml(xml.children.first)

        answers = @fill_plus.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction),
                     (@fill_plus.instance_variable_get :@max_score)
      end

      it "should iterate and contain the right fraction" do
        xml = get_fixture_xml "fill_in_blank_plus.xml"
        @fill_plus = @fill_plus.iterate_xml(xml.children.first)

        answers = @fill_plus.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text), "Dear"
        assert_equal (answers.first.instance_variable_get :@resp_ident), "x"
      end
    end
  end
end
