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

describe "ContentReviewedCriteria" do
  before(:each) do
    @xml = get_fixture_xml("content_reviewed_criteria.xml").
      xpath("./CONTENT_REVIEWED_CRITERIA")
    @content_reviewed = ContentReviewedCriteria.from_xml @xml

    @page_ids = ["res001", "res002"]
    @page_names = ["This Page", "That Page"]
    @module_ids = ["mod1", "mod2", "mod3"]
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
        item.identifier = id
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

  it "should implement from_xml" do
    assert_equal(@content_reviewed.id, "_452522_1")
    assert_equal(@content_reviewed.negated, false)
    assert_equal(@content_reviewed.reviewed_content_id, "res002")
  end

  describe "canvas_conversion" do
    it "should create completion requirement
      for content_reviewed in same module" do
        result = @content_reviewed.canvas_conversion(
          @courses[0], @page_ids.first, Collection.new
        )

        assert_equal result.canvas_modules.size, 1
        assert_equal result.canvas_modules.first.completion_requirements.size, 1
        assert_equal result.canvas_modules.first.prerequisites.size, 0
        comp_req = result.canvas_modules.first.completion_requirements.first
        assert_equal comp_req.identifierref, @page_ids.last
        assert_equal comp_req.type, "must_view"
      end

    it "should create prereq for content_reviewed in different module" do
      result = @content_reviewed.canvas_conversion(
        @courses[1], @page_ids.first, Collection.new
      )

      assert_equal result.canvas_modules.size, 2
      assert_equal result.canvas_modules.first.completion_requirements.size, 0
      assert_equal result.canvas_modules.first.prerequisites.size, 1
      prereq = result.canvas_modules.first.prerequisites.first
      assert_equal prereq.identifierref, @modules[2].identifier
    end
  end
end
