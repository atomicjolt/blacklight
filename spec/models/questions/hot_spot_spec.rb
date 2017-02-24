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
  describe "HotSpot" do
    before do
      @hot_spot = HotSpot.new
    end

    describe "initialize" do
      it "should initialize hot_spot" do
        assert_equal (@hot_spot.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml and have one answer" do
        xml = get_fixture_xml "hot_spot.xml"
        @hot_spot = @hot_spot.iterate_xml(xml.children.first)

        assert_includes (@hot_spot.instance_variable_get :@material),
                        (@hot_spot.instance_variable_get :@title)
        assert_includes (@hot_spot.instance_variable_get :@material),
                        "This question was imported from an"
        assert_includes (@hot_spot.instance_variable_get :@material),
                        "external source. It was a Hot Spot question, which"
        assert_includes (@hot_spot.instance_variable_get :@material),
                        "is not supported in this quiz tool."
      end
    end
  end
end
