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
require_relative "../../lib/senkyoshi/models/wikipage"

describe "WikiPage" do
  before do
    @xml = get_fixture_xml "content.xml"
    @id = "res001"
    @pre_data = { file_name: @id, referred_to_title: "/Content/Test Test" }
    @page = Senkyoshi::WikiPage.new(@id)

    @page.iterate_xml(@xml, @pre_data)
  end

  it "should iterate_xml" do
    page_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
    page_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

    assert_equal(@page.id, @id)
    assert_equal(@page.title, page_title)
    assert_equal(@page.body, page_body)
    assert_equal(@page.files.length, 1)
    assert_equal(@page.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new

    result = @page.canvas_conversion(course, Senkyoshi::Collection.new)

    assert_equal(result.pages.size, 1)
    assert_equal(result.pages.first.identifier, @id)
  end

  it "should include extended data" do
    page_extendeddata = @xml.at("/CONTENT/EXTENDEDDATA/ENTRY").text
    assert_equal @page.extendeddata, page_extendeddata
  end

  it "should include course link in body" do
    course = CanvasCc::CanvasCC::Models::Course.new
    course = @page.canvas_conversion(course, Senkyoshi::Collection.new)

    page_body = course.pages.first.body.gsub(/\s+/, " ")
    expected_link_text = '<a href="%24CANVAS_COURSE_REFERENCE%24/Content/' \
      'Test%20Test"> Course Link: /Content/Test Test </a>'

    assert_includes(page_body, expected_link_text)
  end
end
