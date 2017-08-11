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

require_relative "../../lib/senkyoshi/models/link"

include Senkyoshi

describe Senkyoshi do
  describe "get_pre_data" do
    it "should return the correct data" do
      link_xml = get_fixture_xml "link.xml"
      link_pre_data = Link.get_pre_data(link_xml, nil)

      assert_equal("res00053", link_pre_data[:referrer])
      assert_equal("res00030", link_pre_data[:referred_to])
      assert_equal("/Content/Test Test", link_pre_data[:referred_to_title])
    end
  end
end
