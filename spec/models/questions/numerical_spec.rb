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

include Senkyoshi

describe Senkyoshi do
  describe "NumericalQuestion" do
    before do
      @numeric = NumericalQuestion.new
    end

    describe "initialize" do
      it "should initialize numeric" do
        assert_equal (@numeric.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.count, 1
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        tolerances = @numeric.instance_variable_get :@tolerances

        assert_equal tolerances, {}
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges
        answers = @numeric.instance_variable_get :@answers

        assert_equal answers.first.id, ranges.first.first
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.first.last.low_range, 137
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        ranges = @numeric.instance_variable_get :@ranges

        assert_equal ranges.first.last.high_range, 167
      end

      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "numeric.xml"
        @numeric = @numeric.iterate_xml(xml.children.first)
        answers = @numeric.instance_variable_get :@answers
        max_score = @numeric.instance_variable_get :@max_score

        assert_equal answers.first.fraction, max_score
      end
    end
  end
end
