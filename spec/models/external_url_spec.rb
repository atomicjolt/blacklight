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
require_relative "../../lib/senkyoshi/models/external_url"

describe "ExternalUrl" do
  it "implements canvas_conversion" do
    xml = get_fixture_xml "external_url.xml"
    course = CanvasCc::CanvasCC::Models::Course.new
    external_url = Senkyoshi::ExternalUrl.new
    external_url.iterate_xml(xml, {})

    result = external_url.canvas_conversion(course, nil)
    assert_equal(result.canvas_modules.size, 1)
    c_module = result.canvas_modules.first

    assert_equal(c_module.title, MASTER_MODULE)
    assert_equal(c_module.module_items.first.url, "http://example.com")
  end
end
