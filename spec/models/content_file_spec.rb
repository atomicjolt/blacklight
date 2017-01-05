require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/content"
require_relative "../mocks/mockzip"

describe "ContentFile" do
  it "should extract data from xml" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))

    assert_equal(file.id, "_2041185_1")
    assert_equal(file.name, "xid-9066097_2/")
    assert_equal(file.linkname, "ADV &amp; DisAdv.pdf")
  end

  it "should implement canvas_conversion" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))
    mock_entry = MockZip::MockEntry.new("ADV &amp;amp; DisAdv.pdf")
    assert_includes(
      file.canvas_conversion(mock_entry),
      "href=\"$IMS_CC_FILEBASE$/#{IMPORTED_FILES_DIRNAME}/ADV",
    )
    assert_includes(
      file.canvas_conversion(mock_entry),
      "ADV &amp;amp; DisAdv.pdf",
    )
  end

  it "should strip only leading slash from name" do
    xml = get_fixture_xml "file.xml"
    file = Senkyoshi::ContentFile.new(xml.xpath("//FILE"))
    refute(file.name.start_with?("/"))
    assert_equal(file.name, "xid-9066097_2/")
  end
end
