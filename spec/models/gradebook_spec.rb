require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/gradebook"

describe "Gradebook" do
  before do
    @id = 1
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

    it "should get_pre_data and return an object" do
      xml = get_fixture_xml "gradebook.xml"
      pre_data = {}

      results = Gradebook.get_pre_data(xml, pre_data).first

      assert_equal results[:category], "Test"
      assert_equal results[:points], "50.0"
      assert_equal results[:content_id], "res00021"
      assert_equal results[:assignment_id], "res00014"
      assert_equal results[:due_at], ""
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
      subject = Gradebook.new.iterate_xml(xml, nil)
      result = subject.get_outcome_definitions xml

      assert_equal(result.size, 4)
      assert_equal(result.map(&:class).uniq, [Senkyoshi::OutcomeDefinition])
    end
  end

  it "should implement canvas_conversion" do
    should_create_quiz = get_fixture_xml("user_created_outcome_definition.xml").
      xpath("./OUTCOMEDEFINITION").first
    should_not_create_quiz = get_fixture_xml("outcome_definition.xml").
      xpath("./OUTCOMEDEFINITION").first

    categories = {
      category_1: "Category One",
      category_2: "Category Two",
    }

    outcome_definitions = [
      OutcomeDefinition.from(should_create_quiz, "Category One"),
      OutcomeDefinition.from(should_not_create_quiz, "Category Two"),
    ]

    subject = Gradebook.new(@id, categories, outcome_definitions)

    course = CanvasCc::CanvasCC::Models::Course.new
    subject.canvas_conversion(course)
    result = course.assignment_groups.map(&:title)

    assert_equal(course.assignments.size, 1)
    assert_equal(course.assignment_groups.size, 2)
    assert_equal(result, ["Category One", "Category Two"])
  end

  describe "convert_categories" do
    it "only creates assignment groups once" do

      categories = {
        category_1: "Category One",
        category_1: "Category One",
        category_2: "Category Two",
      }

      subject = Gradebook.new(@id, categories)

      course = CanvasCc::CanvasCC::Models::Course.new
      subject.canvas_conversion(course)

      result = course.assignment_groups.map(&:title)
      assert_equal(result, ["Category One", "Category Two"])
    end
  end
end
