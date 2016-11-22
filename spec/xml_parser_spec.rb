require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
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
