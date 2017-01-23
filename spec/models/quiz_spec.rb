require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/quiz"

describe "Quiz" do
  before do
    @xml = get_fixture_xml "quiz.xml"
    @id = "res001"
    @pre_data = { file_name: @id }
  end

  it "should iterate_xml" do
    quiz = Senkyoshi::Quiz.new(@id)
    quiz.iterate_xml(@xml, @pre_data)

    quiz_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
    quiz_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

    assert_equal(quiz.id, @id)
    assert_equal(quiz.title, quiz_title)
    assert_equal(quiz.body, quiz_body)
    assert_equal((quiz.instance_variable_get :@module_type), "Quizzes::Quiz")
    assert_equal(quiz.body, quiz_body)
  end

  it "should convert to canvas module item" do
    quiz = Senkyoshi::Quiz.new(@id)
    quiz.iterate_xml(@xml, @pre_data)

    assert_equal((quiz.instance_variable_get :@module_item).
      content_type, "Quizzes::Quiz")
    assert_equal((quiz.instance_variable_get :@module_item).
      identifierref, @id)
  end
end
