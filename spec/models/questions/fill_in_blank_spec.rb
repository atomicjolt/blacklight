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
  describe "FillInBlank" do
    before do
      @fill_in_blank = FillInBlank.new
    end

    describe "initialize" do
      it "should initialize fill_in_blank" do
        assert_equal (@fill_in_blank.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "fill_in_blank.xml"
        @fill_in_blank = @fill_in_blank.iterate_xml(xml.children.first)

        answers = @fill_in_blank.instance_variable_get :@answers
        assert_includes (answers.first.instance_variable_get :@answer_text),
                        "Hay"
      end

      it "should iterate and contain the right fraction" do
        xml = get_fixture_xml "fill_in_blank.xml"
        @fill_in_blank = @fill_in_blank.iterate_xml(xml.children.first)

        answers = @fill_in_blank.instance_variable_get :@answers
        assert_equal (answers.first.instance_variable_get :@fraction),
                     (@fill_in_blank.instance_variable_get :@max_score)
      end
    end
  end
end
