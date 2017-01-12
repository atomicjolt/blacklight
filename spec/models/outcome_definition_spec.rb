require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/gradebook"

describe "OutcomeDefinition" do
  it "should create self from xml" do
    xml = get_fixture_xml "outcome_definition.xml"
    category_id = "asdf123"
    result = OutcomeDefinition.from(
      xml.xpath("./OUTCOMEDEFINITION").first, category_id
    )

    assert_equal(result.id, "_3006852_1")
    assert_equal(result.content_id, "res00021")
  end

  it "should implement canvas_conversion" do
    xml = get_fixture_xml("outcome_definition.xml").
      xpath("./OUTCOMEDEFINITION").first
    subject = OutcomeDefinition.from(xml, "category_name")

    course = CanvasCc::CanvasCC::Models::Course.new
    subject.canvas_conversion(course)

    result = course.assignments.first

    assert_equal(course.assignments.size, 1)
    assert_equal(result.title, "All the things")
    assert_equal(result.points_possible, "50.0")
  end
end
