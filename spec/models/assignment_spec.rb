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
require_relative "../../lib/senkyoshi/models/assignment"

describe "Assignment" do
  before do
    @id = "res001"
    @pre_data = { file_name: @id }
    @xml = get_fixture_xml "content.xml"
  end

  it "should iterate_xml" do
    assignment = Senkyoshi::Assignment.new(@id)
    assignment.iterate_xml(@xml, @pre_data)

    assignment_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
    assignment_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

    assert_equal(assignment.id, @id)
    assert_equal(assignment.title, assignment_title)
    assert_equal(assignment.body, assignment_body)
    assert_equal(assignment.files.length, 1)
    assert_equal(assignment.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    assignment = Senkyoshi::Assignment.new(@id)
    assignment.iterate_xml(@xml, @pre_data)

    result = assignment.canvas_conversion(course, Senkyoshi::Collection.new)

    assert_equal(result.assignments.size, 1)
    assert_equal(result.assignments.first.identifier, @id)
  end
end
