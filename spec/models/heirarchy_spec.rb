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
require_relative "../../lib/senkyoshi/models/heirarchy"

include Senkyoshi

describe Senkyoshi do
  describe "item_iterator" do
    it "should return a toc_item" do
      organizations = get_fixture_xml "organizations.xml"
      resources = get_fixture_xml "resources.xml"
      item = organizations.at("organization").children[3]
      target_type = "CONTENT_ITEM"
      original_file = "res00008"
      internal_handle = "content"
      course_toc = [
        {
          title: "Orientation",
          target_type: "CONTENT_ITEM",
          original_file: "res00007",
          internal_handle: "",
        },
        {
          title: "Pre Information",
          target_type: target_type,
          original_file: original_file,
          internal_handle: internal_handle,
        },
      ]
      discussion_boards = resources.
        search("resource[type=\"resource/x-bb-discussionboard\"]")
      toc_item = Heirarchy.item_iterator(item, course_toc, discussion_boards)
      assert_equal toc_item[:title], "Discussions"
      assert_equal toc_item[:target_type], target_type
      assert_equal toc_item[:file_name], original_file
      assert_equal toc_item[:internal_handle], internal_handle
    end
  end

  describe "get_indent" do
    it "should send an indent number back" do
      organizations = get_fixture_xml "organizations.xml"
      item = organizations.at("organization").children[3]
      indent = Heirarchy.get_indent(item)
      assert_equal indent, -2
    end

    it "should send an indent number back" do
      organizations = get_fixture_xml "organizations.xml"
      item = organizations.at("organization").children[2].children[1]
      indent = Heirarchy.get_indent(item)
      assert_equal indent, -1
    end
  end

  describe "set_discussion_boards" do
    it "should not add the discussion board" do
      resources = get_fixture_xml "resources.xml"
      discussion_boards = resources.
        search("resource[type=\"resource/x-bb-discussionboard\"]")
      file_name = "res00005"
      toc_item = {
        title: "Seminar 6",
        target_type: "MODULE",
        original_file: "res00005",
        internal_handle: "",
        file_name: file_name,
        parent_id: nil,
        indent: 0,
      }
      item = Heirarchy.set_discussion_boards(discussion_boards, toc_item)
      assert_equal toc_item, item
      assert_equal toc_item[:file_name], file_name
    end

    it "should not add the discussion board" do
      resources = get_fixture_xml "resources.xml"
      discussion_boards = resources.
        search("resource[type=\"resource/x-bb-discussionboard\"]")
      file_name = "res00005"
      toc_item = {
        title: "CWPC Home Page",
        target_type: "MODULE",
        original_file: "res00005",
        internal_handle: "discussion_board_entry",
        file_name: file_name,
        parent_id: nil,
        indent: 0,
      }
      item = Heirarchy.set_discussion_boards(discussion_boards, toc_item)
      assert_equal toc_item, item
      assert_equal toc_item[:file_name], file_name
    end

    it "should add the discussion board with right file name" do
      file_name = "res00005"
      toc_item = {
        title: "Seminar 6",
        target_type: "MODULE",
        original_file: "res00005",
        internal_handle: "discussion_board_entry",
        file_name: file_name,
        parent_id: nil,
        indent: 0,
      }
      assert_equal toc_item[:file_name], file_name
    end
  end

  describe "setup_item" do
    it "should setup the item" do
      organizations = get_fixture_xml "organizations.xml"
      item = organizations.at("organization").children[3]
      target_type = "CONTENT_ITEM"
      original_file = "res00008"
      internal_handle = "content"
      course_toc = [
        {
          title: "Orientation",
          target_type: "SUBHEADER",
          original_file: "res00007",
          internal_handle: "",
        },
        {
          title: "Pre Information",
          target_type: target_type,
          original_file: original_file,
          internal_handle: internal_handle,
        },
      ]
      toc_item = Heirarchy.setup_item(item, item.parent, course_toc)
      assert_equal toc_item[:target_type], target_type
      assert_equal toc_item[:file_name], original_file
      assert_equal toc_item[:internal_handle], internal_handle
    end

    it "should setup the item" do
      organizations = get_fixture_xml "organizations.xml"
      item = organizations.at("organization").children[3]
      target_type = "CONTENT_ITEM"
      original_file = "res00008"
      internal_handle = "content"
      course_toc = [
        {
          title: "Orientation",
          target_type: "SUBHEADER",
          original_file: "res00007",
          internal_handle: "",
        },
        {
          title: "Pre Information",
          target_type: target_type,
          original_file: original_file,
          internal_handle: internal_handle,
        },
      ]
      toc_item = Heirarchy.setup_item(item, item.parent, course_toc)
      assert_equal toc_item[:target_type], target_type
      assert_equal toc_item[:file_name], original_file
      assert_equal toc_item[:internal_handle], internal_handle
    end
  end

  describe "get_parent_id" do
    it "should get the parent id" do
      target_type = "CONTENT_ITEM"
      original_file = "res00008"
      internal_handle = "content"
      item_id = "00008"
      course_toc = [
        {
          title: "Orientation",
          target_type: "SUBHEADER",
          original_file: "res00007",
          internal_handle: "",
        },
        {
          title: "Pre Information",
          target_type: target_type,
          original_file: original_file,
          internal_handle: internal_handle,
        },
      ]
      parent_id = Heirarchy.get_parent_id(course_toc, item_id)
      assert_equal parent_id, "res00007"
    end

    it "should get the parent id" do
      target_type = "CONTENT"
      original_file = "res00008"
      internal_handle = "content"
      item_id = "00008"
      course_toc = [
        {
          title: "Orientation",
          target_type: "CONTENT_ITEM",
          original_file: "res00007",
          internal_handle: "",
        },
        {
          title: "Pre Information",
          target_type: target_type,
          original_file: original_file,
          internal_handle: internal_handle,
        },
      ]
      parent_id = Heirarchy.get_parent_id(course_toc, item_id)
      assert_equal parent_id, "res00008"
    end
  end
end
