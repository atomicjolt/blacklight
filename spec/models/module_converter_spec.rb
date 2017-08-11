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
require_relative "../../lib/senkyoshi/models/module_converter"
require_relative "../../lib/senkyoshi/models/module"

describe "ModuleConverter" do
  before do
    @course = CanvasCc::CanvasCC::Models::Course.new
  end

  describe "check_module_header" do
    it "return should return true" do
      data = {
        title: "Discussion Board",
        target_type: "CONTENT",
        original_file: "res00006",
        internal_handle: "discussion_board_entry",
        file_name: "res00006",
        parent_id: nil,
        indent: 0,
      }
      subheaders = []
      result = ModuleConverter.check_module_header(data, subheaders)
      assert_equal result, true
    end
    it "return should return true" do
      data = {
        title: "Discussion Board",
        target_type: "SUBHEADER",
        original_file: "res00006",
        internal_handle: "discussion_board_entry",
        file_name: "res00006",
        parent_id: nil,
        indent: 0,
      }
      subheaders = []
      result = ModuleConverter.check_module_header(data, subheaders)
      assert_equal result, true
    end
    it "return should return false" do
      data = {
        title: "Discussion Board",
        target_type: "CONTENT",
        original_file: "res00006",
        internal_handle: "discussion_board_entry",
        file_name: "res00006",
        parent_id: "res00001",
        indent: 0,
      }
      subheaders = [{ name: "subheader" }]
      result = ModuleConverter.check_module_header(data, subheaders)
      assert_equal result, false
    end
  end

  describe "get_subheaders" do
    it "should return no subheaders" do
      pre_data = [
        {
          title: "Test Home",
          target_type: "CONTENT",
          original_file: "res00005",
          internal_handle: "content",
          file_name: "res00005",
          parent_id: "res00005",
          indent: -1,
        },
        { file_name: "res00082",
          title: "Test Test Version A",
          parent_id: "res00005",
          indent: 0,
          category: "Test",
          points: "78.0",
          content_id: "res00082",
          assignment_id: "res00019",
          due_at: "",
          original_file_name: "res00019",
          one_question_at_a_time: "ALL_AT_ONCE",
          time_limit: "",
          access_code: "Test17Amax",
          allowed_attempts: "",
          unlimited_attempts: "false",
          cant_go_back: "false",
          show_correct_answers: "false" },
      ]
      results = ModuleConverter.get_subheaders(pre_data)
      assert_equal results.length, 0
    end

    it "should return subheaders" do
      pre_data = [
        {
          title: "Test Home",
          target_type: "SUBHEADER",
          original_file: "res00005",
          internal_handle: "content",
          file_name: "res00005",
          parent_id: "res00005",
          indent: -1,
        },
        { file_name: "res00082",
          title: "Test Test Version A",
          parent_id: "res00005",
          indent: 0,
          category: "Test",
          points: "78.0",
          content_id: "res00082",
          assignment_id: "res00019",
          due_at: "",
          original_file_name: "res00019",
          one_question_at_a_time: "ALL_AT_ONCE",
          time_limit: "",
          access_code: "Test17Amax",
          allowed_attempts: "",
          unlimited_attempts: "false",
          cant_go_back: "false",
          show_correct_answers: "false" },
      ]
      results = ModuleConverter.get_subheaders(pre_data)
      assert_equal results.length, 1
    end
  end

  describe "create_module_subheader" do
    it "should create new module subheader" do
      title = "Day 1"
      type = "CONTENT"
      file = "res00020"
      parent = "res00019"
      indent = -1
      data = {
        title: title,
        target_type: type,
        original_file: file,
        internal_handle: "content",
        file_name: file,
        parent_id: parent,
        indent: indent,
      }
      item = ModuleConverter.create_module_subheader(data)

      assert_equal title, item.title
      assert_kind_of CanvasCc::CanvasCC::Models::ModuleItem, item
    end
  end

  describe "add_canvas_module" do
    it "should add the canvas module" do
      title = "Day 1"
      type = "CONTENT"
      file = "res00020"
      parent = "res00019"
      indent = -1
      data = {
        title: title,
        target_type: type,
        original_file: file,
        internal_handle: "content",
        file_name: file,
        parent_id: parent,
        indent: indent,
      }
      item = ModuleConverter.create_module_subheader(data)
      course = CanvasCc::CanvasCC::Models::Course.new
      canvas_course = ModuleConverter.add_canvas_module_item(course, item, data)

      assert_equal canvas_course.canvas_modules.count, 1
      assert_equal canvas_course.canvas_modules.first.module_items.count, 1
      assert_equal canvas_course.canvas_modules.
        first.module_items.first.title, title
    end
  end

  describe "get_subheader_parent" do
    it "should get the subheader parent" do
      course = CanvasCc::CanvasCC::Models::Course.new
      title = "Day 1"
      type = "CONTENT"
      file = "res00020"
      parent = nil
      indent = -1
      identifier = MAIN_CANVAS_MODULE
      data = {
        title: title,
        target_type: type,
        original_file: file,
        internal_handle: "content",
        file_name: file,
        parent_id: parent,
        indent: indent,
      }
      parent_module = Senkyoshi::Module.new(title, identifier).canvas_conversion
      course.canvas_modules << parent_module

      subheader_parent = ModuleConverter.get_subheader_parent(course, data)
      assert_kind_of CanvasCc::CanvasCC::Models::CanvasModule, subheader_parent
      assert_equal subheader_parent.title, title
      assert_equal subheader_parent.identifier, identifier
    end

    it "should get the subheader parent" do
      course = CanvasCc::CanvasCC::Models::Course.new
      title = "Day 1"
      type = "CONTENT"
      file = "res00020"
      parent = "res00019"
      indent = -1
      data = {
        title: title,
        target_type: type,
        original_file: file,
        internal_handle: "content",
        file_name: file,
        parent_id: parent,
        indent: indent,
      }
      parent_module = Senkyoshi::Module.new(title, parent).canvas_conversion
      course.canvas_modules << parent_module

      subheader_parent = ModuleConverter.get_subheader_parent(course, data)
      assert_kind_of CanvasCc::CanvasCC::Models::CanvasModule, subheader_parent
      assert_equal subheader_parent.title, title
      assert_equal subheader_parent.identifier, parent
    end

    it "should get the subheader parent" do
      course = CanvasCc::CanvasCC::Models::Course.new
      title = "Day 1"
      type = "CONTENT"
      file = "res00020"
      parent = "res00019"
      unknown_parent = "res00021"
      indent = -1
      data = {
        title: title,
        target_type: type,
        original_file: file,
        internal_handle: "content",
        file_name: file,
        parent_id: unknown_parent,
        indent: indent,
      }
      parent_module = Senkyoshi::Module.new(title, parent).canvas_conversion
      course.canvas_modules << parent_module

      subheader_parent = ModuleConverter.get_subheader_parent(course, data)
      assert_nil subheader_parent
    end
  end
end
