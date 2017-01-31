require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "../helpers.rb"

describe "GradeRangePercentCriteria" do
  before do
    @xml = get_fixture_xml("rule_grade_range_percent_criteria.xml").
      xpath(".//GRADE_RANGE_PERCENT_CRITERIA")
  end

  it "should implement from_xml" do
    result = GradeRangePercentCriteria.from_xml(@xml)

    assert_equal result.id, "_453959_1"
    assert_equal result.negated, false
    assert_equal result.outcome_def_id, "_468265_1"
    assert_equal result.min_score, "100.0"
  end

  it "should calculate percentages" do
    assert_equal(GradeRangePercentCriteria.get_percentage("50", "12"), 6.0)
    assert_equal(GradeRangePercentCriteria.get_percentage("0", "12"), 0.0)
  end
end
