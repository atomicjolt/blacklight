require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/wikipage"

describe "WikiPage" do
  before do
    @xml = get_fixture_xml "content.xml"
    @id = "res001"
    @pre_data = { file_name: @id }
  end
  it "should iterate_xml" do
    page = Senkyoshi::WikiPage.new(@id)
    page.iterate_xml(@xml, @pre_data)

    page_title = @xml.xpath("/CONTENT/TITLE/@value").first.text
    page_body = @xml.xpath("/CONTENT/BODY/TEXT").first.text

    assert_equal(page.id, @id)
    assert_equal(page.title, page_title)
    assert_equal(page.body, page_body)
    assert_equal(page.files.length, 1)
    assert_equal(page.files.first.id, "_2030185_1")
  end

  it "should convert to canvas wiki page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    page = Senkyoshi::WikiPage.new(@id)
    page.iterate_xml(@xml, @pre_data)

    result = page.canvas_conversion(course, Senkyoshi::Collection.new)

    assert_equal(result.pages.size, 1)
    assert_equal(result.pages.first.identifier, @id)
  end

  it "should include extended data" do
    page = Senkyoshi::WikiPage.new(@id)

    page.iterate_xml(@xml, @pre_data)

    page_extendeddata = @xml.at("/CONTENT/EXTENDEDDATA/ENTRY").text
    assert_equal page.extendeddata, page_extendeddata
  end
end
