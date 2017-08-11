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

require_relative "../mocks/mockzip"
require_relative "../../lib/senkyoshi/models/staff_info"

describe "StaffInfo" do
  def setup
    @resources = Senkyoshi::Collection.new
  end

  it "should parse xml" do
    xml = get_fixture_xml("staff_info_1.xml")
    bio = "Contact this office for asistance."
    name = "Mr. Test Name"
    office_hours = "24/7"
    office_address = "123 Fake St."
    home_page = "example.com"
    image = "example.com/image.png"

    staff_info = StaffInfo.new.iterate_xml(xml, nil)

    assert_equal(staff_info.id, "_112170_1")
    assert_equal(staff_info.title, "Test Title")

    assert_includes(staff_info.entries.first, bio)
    assert_includes(staff_info.entries.first, name)
    assert_includes(staff_info.entries.first, office_hours)
    assert_includes(staff_info.entries.first, office_address)
    assert_includes(staff_info.entries.first, home_page)
    assert_includes(staff_info.entries.first, image)
  end

  it "should convert to a single canvas page" do
    course = CanvasCc::CanvasCC::Models::Course.new

    staff_info = StaffInfo.new
    staff_info.iterate_xml(get_fixture_xml("staff_info_1.xml"), nil)
    staff_info.iterate_xml(get_fixture_xml("staff_info_2.xml"), nil)
    staff_info.canvas_conversion course, @resources

    assert_equal(course.pages.size, 1)
    assert_equal(course.pages.first.body.include?("Mr. Test Name"), true)
    assert_equal(course.pages.first.body.include?("Ms. Spec Test"), true)
  end
end
