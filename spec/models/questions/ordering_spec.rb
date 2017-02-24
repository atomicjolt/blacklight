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
  describe "Ordering" do
    before do
      @ordering = Ordering.new
    end

    describe "initialize" do
      it "should initialize ordering" do
        assert_equal (@ordering.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "ordering.xml"
        @ordering = @ordering.iterate_xml(xml.children.first)
        matches = @ordering.instance_variable_get :@matches

        assert_equal matches.count, 4
      end

      it "should iterate through xml and write content to id" do
        xml = get_fixture_xml "ordering.xml"
        @ordering = @ordering.iterate_xml(xml.children.first)
        matches = @ordering.instance_variable_get :@matches

        assert_equal matches.first[:id], "99bba48d2de34e5ea2b2662afa7a2f7e"
      end

      it "should iterate through xml and write content to question text" do
        xml = get_fixture_xml "ordering.xml"
        @ordering = @ordering.iterate_xml(xml.children.first)
        matches = @ordering.instance_variable_get :@matches

        assert_equal matches.first[:question_text], "1"
      end

      it "should iterate through xml and empty answer text" do
        xml = get_fixture_xml "ordering.xml"
        @ordering = @ordering.iterate_xml(xml.children.first)
        matches = @ordering.instance_variable_get :@matches

        assert_equal matches.first[:answer_text], "<p>Oh</p>"
      end

      it "should iterate through xml and set order_answers" do
        xml = get_fixture_xml "ordering.xml"
        @ordering = @ordering.iterate_xml(xml.children.first)
        matches = @ordering.instance_variable_get :@order_answers

        assert_equal matches.count, 4
      end
    end

    describe "set_order_answers" do
      it "should return the ordering answers" do
        xml = get_fixture_xml "ordering.xml"
        resprocessing = xml.search("resprocessing")
        order_answers = @ordering.set_order_answers(resprocessing)

        assert_equal order_answers.count, 4
      end

      it "should return the ordering answers" do
        xml = get_fixture_xml "ordering.xml"
        resprocessing = xml.search("resprocessing")
        order_answers = @ordering.set_order_answers(resprocessing)

        assert_equal order_answers.first,
                     ["99bba48d2de34e5ea2b2662afa7a2f7e", 1]
      end
    end
  end
end
