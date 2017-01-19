require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

describe "ContentReviewedCriteria" do
  before(:each) do
    @xml = get_fixture_xml("content_reviewed_criteria.xml").
      xpath("./CONTENT_REVIEWED_CRITERIA")
    @content_reviewed = ContentReviewedCriteria.from_xml @xml
  end

  it "should implement from_xml" do
    assert_equal(@content_reviewed.id, "_452522_1")
    assert_equal(@content_reviewed.negated, false)
    assert_equal(@content_reviewed.reviewed_content_id, "res00067")
  end

  it "should implement canvas_conversion" do
    course = CanvasCc::CanvasCC::Models::Course.new
    @content_reviewed.canvas_conversion(course)

    #TODO
  end
end
