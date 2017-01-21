require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/assignment"

describe "Assignment" do
  before do
    @id = "res001"
    @pre_data = {file_name: @id}
    @xml = get_fixture_xml "content.xml"
  end

  it "should iterate_xml" do
    assignment = Senkyoshi::Assignment.new(@id)
    assignment.iterate_xml(@xml, @pre_data)

    assignment_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
    assignment_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

    assert_equal(assignment.id, @id)
    assert_equal(assignment.title, assignment_title)
    assert_equal(assignment.body, assignment_body)
    assert_equal(assignment.files.length, 1)
    assert_equal(assignment.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    assignment = Senkyoshi::Assignment.new(@id)
    assignment.iterate_xml(@xml, @pre_data)

    result = assignment.canvas_conversion(course, Senkyoshi::Collection.new)

    assert_equal(result.assignments.size, 1)
    assert_equal(result.assignments.first.identifier, @id)
  end
end
