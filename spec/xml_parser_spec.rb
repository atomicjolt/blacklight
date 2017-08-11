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

require_relative "mocks/mockzip"

include Senkyoshi

describe Senkyoshi do
  describe "get_single_pre_data" do
    it "should return a single pre data" do
      id = "res00023"
      parent_id = "res00028"
      master_parent_id = "res00036"
      file_name = "res00002"
      first_data = { id: id, parent_id: parent_id, file_name: file_name }
      pre_data = [first_data,
                  { id: parent_id, parent_id: master_parent_id,
                    file_name: "res00003" },
                  { id: master_parent_id, parent_id: "{unset id}",
                    file_name: "res00004" }]
      result = Senkyoshi.get_single_pre_data(pre_data, file_name)

      assert_equal(result, first_data)
    end
  end

  describe "iterator_master" do
    it "should assign type of 'empty' to empty .dat files" do
      xml = '<resources><resource file="empty.dat" title="Emtpy dat file." ' \
        'identifier="empty" type="resource/x-bb-document"/></resources>'

      xml_resources = Nokogiri::XML.parse(xml).at("resources")
      zip = get_zip_fixture("empty_dat.zip") { |file| file }

      Senkyoshi.iterator_master(xml_resources, zip) do |_xml_data, type, _file|
        assert_equal("empty", type)
      end
    end
  end

  describe "connect_content" do
    it "should return a merged content object" do
      file_name = "res00003"
      parent_id = "res00002"
      assignment_id = "res00015"
      pre_data = {}
      pre_data["content"] = [
        { id: "res00028", parent_id: parent_id, file_name: file_name },
        { id: "res00036", parent_id: "{unset id}", file_name: "res00004" },
      ]
      pre_data["gradebook"] = [[
        {
          category: "Test",
          points: "60",
          content_id: file_name,
          assignment_id: assignment_id,
          due_at: "",
        },
      ]]

      results = Senkyoshi.connect_content(pre_data)
      data = results.detect { |pd| pd[:file_name] == file_name }
      assert_equal results.length, 2
      assert_equal data[:assignment_id], assignment_id
      assert_equal data[:parent_id], parent_id
    end

    it "should return a merged content object" do
      file_name = "res00003"
      parent_id = "res00002"
      assignment_id = "res00015"
      pre_data = {}
      pre_data["content"] = [
        { id: "res00028", parent_id: parent_id, file_name: file_name },
        { id: "res00036", parent_id: "{unset id}", file_name: "res00004" },
      ]
      time_limit = 10
      true_value = "true"
      false_value = "false"
      pre_data["courseassessment"] = [
        {
          original_file_name: assignment_id,
          time_limit: time_limit,
          allowed_attempts: "",
          unlimited_attempts: true_value,
          cant_go_back: true_value,
          show_correct_answers: false_value,
          one_question_at_a_time: "QUESTION_BY_QUESTION",
        },
      ]

      results = Senkyoshi.connect_content(pre_data)
      data = results.detect { |pd| pd[:file_name] == file_name }
      assert_equal results.length, 2
      assert_equal data[:parent_id], parent_id
    end

    it "should return a merged content object with links" do
      file_name_one = "res00028"
      file_name_two = "res00036"
      pre_data = {}

      pre_data["content"] = [
        { file_name: file_name_one },
        { file_name: file_name_two },
      ]

      pre_data["link"] = [
        {
          referrer: file_name_one,
          referred_to: file_name_two,
          referred_to_title: "/Content/Test Item",
        },
      ]

      results = Senkyoshi.connect_content(pre_data)
      content = results.detect { |result| result[:file_name] == file_name_one }
      assert_equal(content[:referred_to_title], "/Content/Test Item")
    end

    it "should return a merged content object" do
      file_name = "res00003"
      parent_id = "res00002"
      assignment_id = "res00015"
      pre_data = {}
      pre_data["content"] = [
        { id: "res00028", parent_id: parent_id, file_name: file_name },
        { id: "res00036", parent_id: "{unset id}", file_name: "res00004" },
      ]
      pre_data["gradebook"] = [[
        {
          category: "Test",
          points: "60",
          content_id: file_name,
          assignment_id: assignment_id,
          due_at: "",
        },
      ]]
      time_limit = 10
      true_value = "true"
      false_value = "false"
      pre_data["courseassessment"] = [
        {
          original_file_name: assignment_id,
          time_limit: time_limit,
          allowed_attempts: "",
          unlimited_attempts: true_value,
          cant_go_back: true_value,
          show_correct_answers: false_value,
          one_question_at_a_time: "QUESTION_BY_QUESTION",
        },
      ]

      results = Senkyoshi.connect_content(pre_data)
      data = results.detect { |pd| pd[:original_file_name] == assignment_id }
      assert_equal results.length, 2
      assert_equal data[:assignment_id], assignment_id
      assert_equal data[:parent_id], parent_id
      assert_equal data[:time_limit], time_limit
    end
  end

  describe "build_heirarchy" do
    it "should return the correct parents to the contents" do
      parent_id = "res00007"
      organizations = get_fixture_xml "organizations.xml"
      resources = get_fixture_xml "resources.xml"
      pre_data = [
        {
          title: "Course Material",
          target_type: "CONTENT",
          original_file: "res00007",
          internal_handle: "content",
          file_name: parent_id,
          parent_id: parent_id,
          indent: -1,
        },
        {
          title: "Discussion Board",
          target_type: "CONTENT",
          original_file: "res00006",
          internal_handle: "discussion_board_entry",
          file_name: "res00006",
          parent_id: nil,
          indent: 0,
        },
      ]
      results = Senkyoshi.build_heirarchy(organizations, resources, pre_data)
      assert_equal(results.last[:parent_id], parent_id)
      assert_equal(results.last[:title], "Help")
      assert_equal(results.last[:indent], 0)
    end
  end

  describe "iterate_files" do
    it "should return array of files" do
      mock_entries = [
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12_1.jpg"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-13_1.jpg"),
        MockZip::MockEntry.new("res/abc/123/test__xid-14_1.jpg"),
        MockZip::MockEntry.new("res/abc/123/test__xid-14_1.jpg.xml"),
        MockZip::MockEntry.new("test.dat"),
      ]

      result = Senkyoshi.iterate_files(MockZip.new(mock_entries))
      assert_equal(result.size, 3)
      assert_equal(result.first.xid, "xid-12_1")
      assert_includes(
        result.first.location,
        "csfiles/home_dir/test__xid-12_1.jpg",
      )
    end
  end

  describe "create_random_hex" do
    it "should return a random string" do
      assert_equal Senkyoshi.create_random_hex.length, 67
    end
  end

  describe "get_attribute_value" do
    it "should not get xml data" do
      id = "randomText"
      title = "Hello"
      type = "title"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.topic_id id
          topic_xml.title title
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_attribute_value(xml_data, type), ""
    end

    it "should get xml data" do
      id = "randomText"
      title = "Hello"
      type = "title"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.topic_id("value" => id)
          topic_xml.title("value" => title)
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_attribute_value(xml_data, type), title
    end
  end

  describe "get_text" do
    it "should not get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.description do |description_xml|
            description_xml.TEXT description
          end
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_text(xml_data, "text"), ""
    end

    it "should get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.description do |description_xml|
            description_xml.TEXT description
          end
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_text(xml_data, "TEXT"), description
    end

    it "should get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.TEXT do |text_xml|
            text_xml.text description
          end
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_text(xml_data, "TEXT"), description
    end
  end

  describe "get_description" do
    it "should get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.description description
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_description(xml_data), ""
    end

    it "should get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.DESCRIPTION do |text_xml|
            text_xml.text description
          end
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_description(xml_data), description
    end

    it "should get xml data" do
      description = "Hello"
      xml_content = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.topicMeta(
          "xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" =>
          "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  " +
          "http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd",
        ) do |topic_xml|
          topic_xml.description do |description_xml|
            description_xml.DESCRIPTION description
          end
        end
      end.to_xml
      xml_data = Nokogiri::XML.parse(xml_content)
      assert_equal Senkyoshi.get_description(xml_data), description
    end
  end
end
