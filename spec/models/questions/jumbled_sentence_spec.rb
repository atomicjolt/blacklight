require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "JumbledSentence" do
    before do
      @jumbled_sentence = JumbledSentence.new
    end

    describe "initialize" do
      it "should initialize jumbled_sentence" do
        assert_equal (@jumbled_sentence.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "jumbled_sentence.xml"
        @jumbled_sentence = @jumbled_sentence.iterate_xml(xml.children.first)

        answers = @jumbled_sentence.instance_variable_get :@answers
        assert_equal answers.count, 1
      end

      it "should iterate through xml and write content to answers" do
        xml = get_fixture_xml "jumbled_sentence.xml"
        @jumbled_sentence = @jumbled_sentence.iterate_xml(xml.children.first)

        answers = @jumbled_sentence.instance_variable_get :@answers

        assert_includes (answers.first.instance_variable_get :@answer_text),
                        "You"
      end

      it "should iterate and contain the right fraction" do
        xml = get_fixture_xml "jumbled_sentence.xml"
        @jumbled_sentence = @jumbled_sentence.iterate_xml(xml.children.first)

        answers = @jumbled_sentence.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), ""
      end

      it "should iterate and contain the right respident" do
        xml = get_fixture_xml "jumbled_sentence.xml"
        @jumbled_sentence = @jumbled_sentence.iterate_xml(xml.children.first)

        answers = @jumbled_sentence.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@resp_ident), "x"
      end

      it "should iterate and contain the right responses" do
        xml = get_fixture_xml "jumbled_sentence.xml"
        @jumbled_sentence = @jumbled_sentence.iterate_xml(xml.children.first)

        responses = @jumbled_sentence.instance_variable_get :@responses
        assert_equal responses.first[:id], "x"
        assert_equal responses[0][:choices].count, 4
        assert_equal responses[0][:choices][0][:text], "You"
      end
    end
  end
end
