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
  describe "Calculated" do
    before do
      @calculated = Calculated.new
    end

    describe "initialize" do
      it "should initialize calculated" do
        assert_equal (@calculated.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      before do
        xml = get_fixture_xml "calculated.xml"
        @calculated = @calculated.iterate_xml(xml.children.first)
      end

      it "should iterate through xml and have one answer" do
        answers = @calculated.answers
        assert_equal answers.count, 1
      end

      it "should iterate through xml and write content to answers" do
        answers = @calculated.answers

        assert_includes answers.first.answer_text, "24"
      end

      it "should populate dataset_definitions" do
        assert_equal @calculated.dataset_definitions.length, 2

        definitions = @calculated.dataset_definitions.sort_by do |definition|
          definition[:name]
        end

        assert_equal definitions.first[:name], "x"
        assert_equal definitions.first[:options], ":10.0:100.0:2"
      end

      it "should populate var_sets" do
        assert_equal @calculated.var_sets.length, 2

        sets = @calculated.var_sets.sort_by { |set| set[:ident] }

        assert_equal sets.first[:ident], "a"
        assert_equal sets.first[:answer], "183.1"

        correct_vars = { "x" => "95.57", "y" => "87.53" }
        assert_equal sets.first[:vars], correct_vars
      end
    end
  end
end
