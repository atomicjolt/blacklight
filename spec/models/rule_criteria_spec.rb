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

describe "RuleCriteria" do
  before do
    @page_ids = ["res001", "res002"]
    @page_names = ["This Page", "That Page"]
    @module_ids = ["asdf", "ghjk", "zxcv"]
    @module_titles = [
      "Fake Module", "Another Fake Module", "Yet Another Fake Module"
    ]

    @courses = [
      CanvasCc::CanvasCC::Models::Course.new,
      CanvasCc::CanvasCC::Models::Course.new,
    ]

    @pages = @page_ids.each_with_index.map do |id, index|
      CanvasCc::CanvasCC::Models::Page.new.tap do |page|
        page.identifier = id
        page.page_name = @page_names[index]
      end
    end

    @module_items = @page_ids.map do |id|
      CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
        item.content_type = "WikiPage"
        item.identifierref = id
      end
    end

    @modules = @module_ids.each_with_index.map do |id, index|
      CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
        mod.identifier = id
        mod.title = @module_titles[index]
      end
    end

    @modules[0].module_items.concat(@module_items)
    @modules[1].module_items << @module_items[0]
    @modules[2].module_items << @module_items[1]

    @courses[0].canvas_modules << @modules[0]
    @courses[1].canvas_modules << @modules[1]
    @courses[1].canvas_modules << @modules[2]
    @courses.each { |course| course.pages.concat(@pages) }
  end

  describe "module_prerequisite?" do
    it "should return true when depends on a resource in another module" do
      result = RuleCriteria.module_prerequisite?(
        @courses[0].canvas_modules, @page_ids[0], @page_ids[1]
      )
      assert_equal result, false
    end

    it "should return false when depends on a resource in same module" do
      result = RuleCriteria.module_prerequisite?(
        @courses[1].canvas_modules, @page_ids[0], @page_ids[1]
      )
      assert_equal result, true
    end
  end

  describe "module_completion?" do
    it "should return false when depends on a resource in another module" do
      result = RuleCriteria.module_completion_requirement?(
        @courses[0].canvas_modules, @page_ids[0], @page_ids[1]
      )
      assert_equal result, true
    end

    it "should return true when depends on a resource in same module" do
      result = RuleCriteria.module_completion_requirement?(
        @courses[1].canvas_modules, @page_ids[0], @page_ids[1]
      )
      assert_equal result, false
    end
  end
end
