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
