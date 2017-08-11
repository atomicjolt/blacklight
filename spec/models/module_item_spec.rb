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
require_relative "../../lib/senkyoshi/models/module_item"

describe "ModuleItem" do
  before do
    @title = "Module Item Name"
    @content_type = "Assignment"
    @identifierref = Senkyoshi.create_random_hex
    @url = "fake/url"
    @indent = 2
    @id = "res00003"
    @module_item = Senkyoshi::ModuleItem.new(
      @title,
      @content_type,
      @identifierref,
      @url,
      @indent,
      @id,
    )
  end

  describe "initialize" do
    it "should initialize module_item" do
      assert_equal (@module_item.is_a? Object), true
      assert_equal (@module_item.instance_variable_get :@title), @title
      assert_equal (@module_item.
        instance_variable_get :@identifierref), @identifierref
    end
  end

  it "should convert to canvas wiki page" do
    result = @module_item.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.content_type, @content_type)
    assert_equal(result.identifierref, @identifierref)
  end
end
