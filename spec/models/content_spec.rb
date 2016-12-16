require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/blacklight/models/content"

describe "Content" do
  it "should iterate_xml" do
    xml = get_fixture_xml "content.xml"
    content = Blacklight::Content.new
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

  it "should convert to canvas wiki page" do
    # course = CanvasCc::CanvasCC::Models::Course.new
    # xml = get_fixture_xml "content.xml"
    # content = Blacklight::Content.new
    # pre_data = {}
    # content.iterate_xml(xml, pre_data)

    # content_id = xml.xpath("/CONTENT/@id").first.text

    # result = content.canvas_conversion(course)

    # assert_equal(result.pages.size, 1)
    # assert_equal(result.pages.first.identifier, content_id)
  end
end
