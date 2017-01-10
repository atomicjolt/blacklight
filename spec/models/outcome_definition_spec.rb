require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/gradebook"

describe "OutcomeDefinition" do
  it "should create self from xml" do
    xml = get_fixture_xml "outcome_definition.xml"
    result = OutcomeDefinition.from_xml(xml.xpath("./OUTCOMEDEFINITION").first)

    assert_equal(result.id, "_3006852_1")
    assert_equal(result.content_id, "res00021")
  end

  # it "should implement canvas_conversion" do
  # end
end
