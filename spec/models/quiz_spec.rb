require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/blacklight/models/quiz"

describe "Quiz" do
  it "should iterate_xml" do
    xml = get_fixture_xml "quiz.xml"
    quiz = Blacklight::Quiz.new
    pre_data = {}
    quiz.iterate_xml(xml, pre_data)

    quiz_title = xml.xpath("/CONTENT/TITLE/@value").first.text
    quiz_body = xml.xpath("/CONTENT/BODY/TEXT").first.text
    quiz_id = xml.xpath("/CONTENT/@id").first.text

    assert_equal(quiz.id, quiz_id)
    assert_equal(quiz.title, quiz_title)
    assert_equal(quiz.body, quiz_body)
    assert_equal((quiz.instance_variable_get :@module_type), "Quizzes::Quiz")
    assert_equal(quiz.body, quiz_body)
  end

  it "should convert to canvas module item" do
    xml = get_fixture_xml "quiz.xml"
    quiz = Blacklight::Quiz.new
    pre_data = {}
    quiz.iterate_xml(xml, pre_data)

    quiz_id = xml.xpath("/CONTENT/@id").first.text

    assert_equal((quiz.instance_variable_get :@module_item).
      content_type, "Quizzes::Quiz")
    assert_equal((quiz.instance_variable_get :@module_item).
      identifierref, quiz_id)
  end
end
