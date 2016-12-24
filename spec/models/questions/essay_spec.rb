require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "Essay" do
    before do
      @essay = Essay.new
    end

    describe "initialize" do
      it "should initialize essay" do
        assert_equal (@essay.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "essay.xml"
        @essay = @essay.iterate_xml(xml.children.first)

        feedback = @essay.instance_variable_get :@general_feedback
        assert_equal feedback, "<p>Just tell me</p>"
      end
    end
  end
end
