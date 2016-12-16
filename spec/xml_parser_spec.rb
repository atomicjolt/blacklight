require "minitest/autorun"

require "blacklight"
require "pry"
require_relative "mocks/mockzip"

include Blacklight

describe Blacklight do
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
      result = Blacklight.get_single_pre_data(pre_data, file_name)

      assert_equal(result, first_data)
    end
  end

  describe "build_heirarchy" do
    it "should return the correct parents to the contents" do
      id = "res00023"
      parent_id = "res00028"
      master_parent_id = "res00036"
      pre_data = [{ id: id, parent_id: parent_id, file_name: "res00002" },
                  { id: parent_id, parent_id: master_parent_id,
                    file_name: "res00003" },
                  { id: master_parent_id, parent_id: "{unset id}",
                    file_name: "res00004" }]
      results = Blacklight.build_heirarchy(pre_data)
      assert_equal(results.first[:parent_id], master_parent_id)
    end
  end

  describe "get_master_parent" do
    it "should return the master parent" do
      id = "res00023"
      parent_id = "res00028"
      master_parent_id = "res00036"
      parents_ids = [master_parent_id, "res00015"]
      pre_data = [{ id: id, parent_id: parent_id, file_name: "res00002" },
                  { id: parent_id, parent_id: master_parent_id,
                    file_name: "res00003" },
                  { id: master_parent_id, parent_id: "{unset id}",
                    file_name: "res00004" }]
      result = Blacklight.get_master_parent(pre_data, parents_ids, parent_id)
      assert_equal(result, master_parent_id)
    end
  end

  describe "iterate_files" do
    it "should return array of files" do
      mock_entries = [
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg"),
      ]

      result = Blacklight.iterate_files(MockZip.new(mock_entries))
      assert_equal(result.size, 2)
      assert_equal(result.first.id, "test__xid-12.jpg")
      assert_includes(
        result.first.location,
        "csfiles/home_dir/test__xid-12.jpg",
      )
    end

    it "should filter metadata files" do
      mock_entries = [
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.xml"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.xml.xml"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg"),
        MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg.xml"),
      ]

      result = Blacklight.iterate_files(MockZip.new(mock_entries))
      assert_equal(result.size, 2)

      file_names = result.map(&:name).sort
      expected_names = %w(test__xid-12.jpg test__xid-12.xml)
      assert_equal(file_names, expected_names)
    end
  end

  describe "create_random_hex" do
    it "should return a random string" do
      assert_equal Blacklight.create_random_hex.length, 32
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
      assert_equal Blacklight.get_attribute_value(xml_data, type), ""
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
      assert_equal Blacklight.get_attribute_value(xml_data, type), title
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
      assert_equal Blacklight.get_text(xml_data, "text"), ""
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
      assert_equal Blacklight.get_text(xml_data, "TEXT"), description
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
      assert_equal Blacklight.get_text(xml_data, "TEXT"), description
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
      assert_equal Blacklight.get_description(xml_data), ""
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
      assert_equal Blacklight.get_description(xml_data), description
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
      assert_equal Blacklight.get_description(xml_data), description
    end
  end
end
