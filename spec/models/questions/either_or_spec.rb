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
  describe "EitherOr" do
    before do
      @either_or = EitherOr.new
    end

    describe "initialize" do
      it "should initialize either_or" do
        assert_equal (@either_or.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "either_or.xml"
        @either_or = @either_or.iterate_xml(xml.children.first)

        answers = @either_or.instance_variable_get :@answers
        assert_equal answers.count, 2
      end

      it "should iterate through xml and write content to answers" do
        xml = get_fixture_xml "either_or.xml"
        @either_or = @either_or.iterate_xml(xml.children.first)

        answers = @either_or.instance_variable_get :@answers
        assert_includes (answers.first.instance_variable_get :@answer_text),
                        EitherOr::EITHER_OR["yes_no.true"]
        assert_equal (answers.first.instance_variable_get :@fraction), 1
        assert_includes (answers.last.instance_variable_get :@answer_text),
                        EitherOr::EITHER_OR["yes_no.false"]
        assert_equal (answers.last.instance_variable_get :@fraction), 0
      end
    end
  end
end
