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

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/content"
require_relative "../mocks/mockzip"

describe "ContentFile" do
  it "should extract data from xml" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))

    assert_equal(file.id, "_2041185_1")
    assert_equal(file.name, "xid-9066097_2/")
    assert_equal(file.linkname, "ADV &amp; DisAdv.pdf")
  end

  it "should implement canvas_conversion" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))
    mock_entry = MockZip::MockEntry.new("ADV &amp;amp; DisAdv.pdf")
    resources = Senkyoshi::Collection.new
    assert_includes(
      file.canvas_conversion(resources, mock_entry),
      "href=\"$IMS-CC-FILEBASE$/ADV",
    )
    assert_includes(
      file.canvas_conversion(resources, mock_entry),
      "ADV &amp;amp; DisAdv.pdf",
    )
  end

  it "should strip only leading slash from name" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))
    refute(file.name.start_with?("/"))
    assert_equal(file.name, "xid-9066097_2/")
  end
end
