require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/wikipage"

describe "WikiPage" do
  it "should iterate_xml" do
    xml = get_fixture_xml "content.xml"
    page = Senkyoshi::WikiPage.new
    pre_data = {}

    page.iterate_xml(xml, pre_data)

    page_title = xml.xpath("/CONTENT/TITLE/@value").first.text
    page_body = xml.xpath("/CONTENT/BODY/TEXT").first.text
    page_id = xml.xpath("/CONTENT/@id").first.text

    assert_equal(page.id, page_id)
    assert_equal(page.title, page_title)
    assert_equal(page.body, page_body)
    assert_equal(page.files.length, 1)
    assert_equal(page.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    xml = get_fixture_xml "content.xml"
    page = Senkyoshi::WikiPage.new
    pre_data = {}
    page.iterate_xml(xml, pre_data)

    page_id = xml.xpath("/CONTENT/@id").first.text

    result = page.canvas_conversion(course, Resource.new)

    assert_equal(result.pages.size, 1)
    assert_equal(result.pages.first.identifier, page_id)
  end
end
