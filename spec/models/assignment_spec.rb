require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/assignment"

describe "Assignment" do
  it "should iterate_xml" do
    xml = get_fixture_xml "content.xml"
    assignment = Senkyoshi::Assignment.new
    pre_data = {}

    assignment.iterate_xml(xml, pre_data)

    assignment_title = xml.xpath("/CONTENT/TITLE/@value").first.text
    assignment_body = xml.xpath("/CONTENT/BODY/TEXT").first.text
    assignment_id = xml.xpath("/CONTENT/@id").first.text

    assert_equal(assignment.id, assignment_id)
    assert_equal(assignment.title, assignment_title)
    assert_equal(assignment.body, assignment_body)
    assert_equal(assignment.files.length, 1)
    assert_equal(assignment.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    xml = get_fixture_xml "content.xml"
    assignment = Senkyoshi::Assignment.new
    pre_data = {}
    assignment.iterate_xml(xml, pre_data)

    assignment_id = xml.xpath("/CONTENT/@id").first.text

    result = assignment.canvas_conversion(course, Resource.new)

    assert_equal(result.assignments.size, 1)
    assert_equal(result.assignments.first.identifier, assignment_id)
  end
end
