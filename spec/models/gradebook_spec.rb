require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/gradebook"

describe "Gradebook" do
  before do
    @gradebook = Senkyoshi::Gradebook.new
  end

  describe "initialize" do
    it "should initialize gradebook" do
      assert_equal (@gradebook.is_a? Object), true
    end
  end

  describe "get_pre_data" do
    it "should get_pre_data and return an object" do
      xml = get_fixture_xml "gradebook.xml"
      pre_data = {}
      count = xml.search("OUTCOMEDEFINITIONS").children.length

      results = Gradebook.get_pre_data(xml, pre_data)
      assert_equal(results.length, count)
    end
  end

  describe "get_categories" do
    it "should get_categories and return categories" do
      xml = get_fixture_xml "gradebook.xml"
      count = xml.at("CATEGORIES").children.length

      categories = Gradebook.get_categories(xml)
      assert_equal(categories.length, count)
    end
  end

  describe "get_outcome_definitions" do
    it "should return all outcome definitions" do
      xml = get_fixture_xml "gradebook.xml"
      result = Gradebook.get_outcome_definitions xml

      assert_equal(result.size, 4)
      assert_equal(result.map(&:class).uniq, [Senkyoshi::OutcomeDefinition])
    end
  end

  it "should implement canvas_conversion" do
    not_quiz = OutcomeDefinition.new(1, "", nil, nil)
    quiz = OutcomeDefinition.new(2, "res001", nil, nil)

    subject = Gradebook.new
    subject.outcome_definitions = [not_quiz, quiz]

    course = CanvasCc::CanvasCC::Models::Course.new
    subject.canvas_conversion(course)
    refute(course.assignments.size, 0)
    # TODO expect changes in course
  end
end
