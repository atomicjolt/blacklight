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
  describe "MultipleAnswer" do
    before do
      @multiple_answer = MultipleAnswer.new
    end

    describe "initialize" do
      it "should initialize multiple_answer" do
        assert_equal (@multiple_answer.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)

        answers = @multiple_answer.instance_variable_get :@answers
        assert_equal answers.count, 4
      end

      it "should iterate through xml and have multiple answer" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)

        answers = @multiple_answer.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@answer_text),
                     "<p>Answer 1</p>"
      end

      it "should iterate through xml and have correct fraction" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)

        answers = @multiple_answer.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction), 0.0
      end
    end

    describe "set_correct_answer" do
      it "should set correct answers" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)
        resprocessing = xml.children.at("resprocessing")

        correct_answers = @multiple_answer.set_correct_answer(resprocessing)
        assert_equal correct_answers.count, 2
      end

      it "should set correct answers" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)
        resprocessing = xml.children.at("resprocessing")

        correct_answers = @multiple_answer.set_correct_answer(resprocessing)
        assert_equal correct_answers.first.last["fraction"],
                     (@multiple_answer.instance_variable_get :@max_score).to_f
      end
    end

    describe "set_incorrect_answer" do
      it "should set incorrect answers" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)
        resprocessing = xml.children.at("resprocessing")

        incorrect_answers = @multiple_answer.set_incorrect_answer(resprocessing)
        assert_equal incorrect_answers.count, 1
      end

      it "should set incorrect answers" do
        xml = get_fixture_xml "multiple_answer.xml"
        @multiple_answer = @multiple_answer.iterate_xml(xml.children.first)
        resprocessing = xml.children.at("resprocessing")

        incorrect_answers = @multiple_answer.set_incorrect_answer(resprocessing)
        assert_equal incorrect_answers["fraction"], 0
      end
    end
  end
end
