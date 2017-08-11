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
  describe "MultipleChoice" do
    before do
      @multiple_choice = MultipleChoice.new
    end

    describe "initialize" do
      it "should initialize multiple_choice" do
        assert_equal (@multiple_choice.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal answers.count, 4
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text),
                     "<p>I am just kidding</p>"
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 0.0
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "multiple_choice.xml"
        @multiple_choice = @multiple_choice.iterate_xml(xml.children.first)

        answers = @multiple_choice.instance_variable_get :@answers
        assert_equal (answers[1].instance_variable_get :@fraction), 1.0
      end
    end
  end
end
