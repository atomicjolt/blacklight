# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
