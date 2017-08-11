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
require_relative "../../lib/senkyoshi/models/module"

describe "Module" do
  before do
    @title = "Module Name"
    @identifier = Senkyoshi.create_random_hex
    @module = Senkyoshi::Module.new(@title, @identifier)
    @url = "fake/url"
    @module_ids = ["1", "2"]

    @canvas_modules = @module_ids.map do |id|
      CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
        mod.identifier = id
      end
    end

    @page_ids = ["res001", "res002"]
    @canvas_pages = @page_ids.map do |id|
      CanvasCc::CanvasCC::Models::Page.new.tap do |page|
        page.identifier = id
      end
    end

    @canvas_module_items = @page_ids.map do |id|
      CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
        item.identifierref = id
      end
    end

    @canvas_modules.each_with_index do |mod, index|
      mod.module_items << @canvas_module_items[index]
    end
    @indent = 0
    @id = "res00004"
  end

  describe "initialize" do
    it "should initialize module" do
      assert_equal (@module.is_a? Object), true
      assert_equal (@module.instance_variable_get :@title), @title
      assert_equal (@module.instance_variable_get :@identifier), @identifier
    end
  end

  describe "find_module_from_item_id" do
    it "should return module that module item belongs to" do
      result = Senkyoshi::Module.find_module_from_item_id(
        @canvas_modules, @canvas_module_items.first.identifierref
      )

      assert_equal result.identifier, @module_ids.first
    end

    it "should return nil when item is not found" do
      result = Senkyoshi::Module.find_module_from_item_id(
        @canvas_modules, "bad id"
      )

      refute result
    end
  end

  it "should convert to canvas wiki page" do
    result = @module.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.identifier, @identifier)
    assert_equal(result.module_items.count, 0)
  end

  it "should convert to canvas wiki page" do
    module_item = Senkyoshi::ModuleItem.new(
      @title,
      @content_type,
      @identifierref,
      @url,
      @indent,
      @id,
    )

    @module.module_items << module_item
    result = @module.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.identifier, @identifier)
    assert_equal(result.module_items.count, 1)
  end
end
