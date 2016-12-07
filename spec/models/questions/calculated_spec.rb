require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "Calculated" do
    before do
      @calculated = Calculated.new
    end

    describe "initialize" do
      it "should initialize calculated" do
        assert_equal (@calculated.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "calculated.xml"
        @calculated = @calculated.iterate_xml(xml.children.first)

        answers = @calculated.instance_variable_get :@answers
        assert_equal answers.count, 1
      end

      it "should iterate through xml and right content to answers" do
        xml = get_fixture_xml "calculated.xml"
        @calculated = @calculated.iterate_xml(xml.children.first)

        answers = @calculated.instance_variable_get :@answers

        assert_includes (answers.first.instance_variable_get :@answer_text),
                        "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
        assert_includes (answers.first.instance_variable_get :@answer_text),
                        "<mroot><msup><mn>24</mn><mrow/></msup><mrow/></mroot>"
      end

      it "should iterate and contain the right fraction" do
        xml = get_fixture_xml "calculated.xml"
        @calculated = @calculated.iterate_xml(xml.children.first)

        answers = @calculated.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 1
      end
    end
  end
end
