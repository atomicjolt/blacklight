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
require_relative "../../lib/senkyoshi/models/content"

describe "Content" do
  before do
    @id = "res001"
    @pre_data = { file_name: @id }
    @xml = get_fixture_xml "content.xml"
  end

  describe "from" do
    it "should return the right content type" do
      result = Content.from(@xml, @pre_data, [])
      assert_equal (result.is_a? Object), true
      assert_equal (result.is_a? WikiPage), true
    end
  end

  describe "iterate_xml" do
    it "should iterate_xml" do
      content = Senkyoshi::Content.new(@id)
      content.iterate_xml(@xml, @pre_data)

      content_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
      content_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

      assert_equal(content.id, @id)
      assert_equal(content.title, content_title)
      assert_equal(content.body, content_body)
      assert_equal(content.files.length, 1)
      assert_equal(content.files.first.id, "_2030185_1")
    end
  end

  describe "set_module" do
    it "should return the converted module item" do
      xml = get_fixture_xml "content.xml"
      content = Senkyoshi::Attachment.new
      pre_data = {}
      result = content.iterate_xml(xml, pre_data)

      id = xml.xpath("/CONTENT/FILES/FILE/NAME").first.text.gsub("/", "")
      title = xml.xpath("/CONTENT/TITLE/@value").first.text

      assert_equal((result.instance_variable_get :@module_item).
        content_type, "Attachment")
      assert_equal((result.instance_variable_get :@module_item).
        identifierref, id)
      assert_equal((result.instance_variable_get :@module_item).title, title)
    end
  end

  describe "create_module" do
    it "should return a module" do
      xml = get_fixture_xml "content.xml"
      content = Senkyoshi::Content.new
      pre_data = {
        parent_id: MASTER_MODULE,
      }
      content = content.iterate_xml(xml, pre_data)
      course = CanvasCc::CanvasCC::Models::Course.new

      result = content.create_module(course)

      assert_equal(result.canvas_modules.size, 1)

      assert_equal(result.canvas_modules.first.identifier, (content.
        instance_variable_get :@parent_id))
    end
  end
end
