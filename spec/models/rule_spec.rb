require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

describe "Rule" do
  before do
    @id = "res001"
  end

  it "should implement iterate_xml" do
    xml = get_fixture_xml("rule.xml").xpath("./RULE")

    result = Senkyoshi::Rule.new(@id).iterate_xml xml

    assert_equal result.title, "Rule 1"
    assert_equal result.content_id, "res002"
    assert_equal result.criteria_list.size, 2
    assert_equal result.criteria_list.first.class, GradeCompletedCriteria
    assert_equal result.criteria_list[1].class, ContentReviewedCriteria
  end
end
