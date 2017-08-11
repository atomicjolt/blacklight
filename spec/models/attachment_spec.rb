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
require_relative "../../lib/senkyoshi/models/attachment"

describe "Attachment" do
  it "creates module_item" do
    xml = get_fixture_xml "attachment.xml"
    attachment = Senkyoshi::Attachment.new
    result = attachment.iterate_xml(xml, {})
    result_module = result.instance_variable_get("@module_item")

    assert_equal(result_module.content_type, "Attachment")
    assert_equal(result_module.title, "IP-135")
  end

  it "implements canvas_conversion" do
    xml = get_fixture_xml "attachment.xml"
    course = CanvasCc::CanvasCC::Models::Course.new
    attachment = Senkyoshi::Attachment.new
    attachment.iterate_xml(xml, {})

    result = attachment.canvas_conversion(course, nil)
    assert_equal(result.canvas_modules.size, 1)
    assert_equal(result.canvas_modules.first.title, MASTER_MODULE)
  end
end
