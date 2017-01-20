require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/content"

describe "Content" do
  describe "from" do
    it "should return the right content type" do
      xml = get_fixture_xml "content.xml"
      result = Content.from(xml, {}, [])
      assert_equal (result.is_a? Object), true
      assert_equal (result.is_a? WikiPage), true
    end
  end

  describe "iterate_xml" do
    it "should iterate_xml" do
      xml = get_fixture_xml "content.xml"
      content = Senkyoshi::Content.new
      pre_data = {}
      content.iterate_xml(xml, pre_data)

      content_title = xml.xpath("/CONTENT/TITLE/@value").first.text
      content_body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      content_id = xml.xpath("/CONTENT/@id").first.text

      assert_equal(content.id, content_id)
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
        parent_id: "master_module",
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
