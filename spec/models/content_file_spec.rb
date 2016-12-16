require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/blacklight/models/content"

describe "ContentFile" do
  it "should extract data from xml" do
    xml = get_fixture_xml "file.xml"
    file = Blacklight::ContentFile.new(xml.xpath("//FILE"))

    assert_equal(file.id, "_2041185_1")
    assert_equal(file.name, "/xid-9066097_2")
    assert_equal(file.linkname, "ADV &amp; DisAdv.pdf")
  end

  it "should implement canvas_conversion" do
    xml = get_fixture_xml "file.xml"
    file = Blacklight::ContentFile.new(xml.xpath("//FILE"))
    assert_includes(
      file.canvas_conversion,
      "<a href='$IMS_CC_FILEBASE$/ADV " \
      "&amp; DisAdv.pdf'>ADV &amp; DisAdv.pdf</a>",
    )
  end
end
