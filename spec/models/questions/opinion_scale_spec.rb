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
  describe "OpinionScale" do
    before do
      @opinion_scale = OpinionScale.new
    end

    describe "initialize" do
      it "should initialize opinion_scale" do
        assert_equal (@opinion_scale.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal answers.count, 6
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text),
                     "<p>Strongly Agree</p>"
      end

      it "should iterate through xml and have incorrect fraction" do
        xml = get_fixture_xml "opinion.xml"
        @opinion_scale = @opinion_scale.iterate_xml(xml.children.first)

        answers = @opinion_scale.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 1.0
      end
    end
  end
end
