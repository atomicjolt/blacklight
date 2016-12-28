require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "TrueFalse" do
    before do
      @true_false = TrueFalse.new
    end

    describe "initialize" do
      it "should initialize true_false" do
        assert_equal (@true_false.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @true_false = @true_false.iterate_xml(xml.children.first)

        answers = @true_false.instance_variable_get :@answers
        assert_equal answers.count, 2
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @true_false = @true_false.iterate_xml(xml.children.first)

        answers = @true_false.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text), true
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @true_false = @true_false.iterate_xml(xml.children.first)

        answers = @true_false.instance_variable_get :@answers
        assert_equal (answers.last.instance_variable_get :@answer_text), false
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "opinion.xml"
        @true_false = @true_false.iterate_xml(xml.children.first)

        answers = @true_false.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 0.0
      end
    end
  end
end
