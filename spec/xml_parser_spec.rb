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

  describe "build_heirarchy" do
    it "should return the correct parents to the contents" do
      id = "res00023"
      parent_id = "res00028"
      master_parent_id = "res00036"
      organizations = get_fixture_xml "organizations.xml"
      pre_data = [{ id: id, parent_id: parent_id, file_name: "res00002" },
                  { id: parent_id, parent_id: parent_id,
                    file_name: "res00003" },
                  { id: master_parent_id, parent_id: "{unset id}",
                    file_name: "res00004" }]
      results = Senkyoshi.build_heirarchy(organizations, pre_data)
      assert_equal(results.first[:parent_id], parent_id)
      assert_nil(results.first[:title])
      assert_equal(results.last[:title], "Home Page")
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

  describe "iterate_files" do
    it "should return array of files" do
      mock_entries = [
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12_1.jpg"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-13_1.jpg"),
        MockZip::MockEntry.new("res/abc/123/test__xid-14_1.jpg"),
        MockZip::MockEntry.new("res/abc/123/test__xid-14_1.jpg.xml"),
        MockZip::MockEntry.new("res/abc/123/test__xid-15_1.jpg"),
        MockZip::MockEntry.new("test.dat"),
      ]

      result = Senkyoshi.iterate_files(MockZip.new(mock_entries))
      assert_equal(result.size, 7)# 4 files + 3 directories = 6
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
