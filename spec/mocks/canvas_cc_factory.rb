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

def make_fake_course_with_single_module
  page_ids = ["res001", "res002"]
  page_names = ["This Page", "That Page"]
  module_ids = ["mod1"]
  module_titles = ["Fake Module"]

  courses = [CanvasCc::CanvasCC::Models::Course.new]

  pages = page_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::Page.new.tap do |page|
      page.identifier = id
      page.page_name = page_names[index]
    end
  end

  module_items = page_ids.map do |id|
    CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
      item.content_type = "WikiPage"
      item.identifierref = id
      item.identifier = id
    end
  end

  modules = module_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
      mod.identifier = id
      mod.title = module_titles[index]
    end
  end

  modules[0].module_items.concat(module_items)

  courses[0].canvas_modules << modules[0]
  courses.each { |course| course.pages.concat(pages) }
  courses[0]
end

def make_fake_courses_with_two_modules
  page_ids = ["res001", "res002"]
  page_names = ["This Page", "That Page"]
  module_ids = ["mod1", "mod2", "mod3"]
  module_titles = [
    "Fake Module", "Another Fake Module", "Yet Another Fake Module"
  ]

  courses = [
    CanvasCc::CanvasCC::Models::Course.new,
    CanvasCc::CanvasCC::Models::Course.new,
  ]

  pages = page_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::Page.new.tap do |page|
      page.identifier = id
      page.page_name = page_names[index]
    end
  end

  module_items = page_ids.map do |id|
    CanvasCc::CanvasCC::Models::ModuleItem.new.tap do |item|
      item.content_type = "WikiPage"
      item.identifierref = id
      item.identifier = id
    end
  end

  modules = module_ids.each_with_index.map do |id, index|
    CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |mod|
      mod.identifier = id
      mod.title = module_titles[index]
    end
  end

  modules[0].module_items.concat(module_items)
  modules[1].module_items << module_items[0]
  modules[2].module_items << module_items[1]

  courses[0].canvas_modules << modules[0]
  courses[1].canvas_modules << modules[1]
  courses[1].canvas_modules << modules[2]
  courses.each { |course| course.pages.concat(pages) }

  courses
end
