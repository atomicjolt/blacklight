require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../mocks/mockzip"
require_relative "../../lib/blacklight/models/file"

describe "BlacklightFile" do
  before do
    @path = "fake/path/to/file__xid-1234_1.txt"
    entry = MockZip::MockEntry.new(@path)
    @file = Blacklight::BlacklightFile.new(entry)
  end

  it "should iterate_xml" do
    assert_equal(@file.id, "file__xid-1234_1.txt")
    assert_equal(@file.name, "file.txt")
    assert_includes(@file.location, @path)
  end

  it "should convert to canvas file " do
    course = CanvasCc::CanvasCC::Models::Course.new

    result = @file.canvas_conversion(course)

    assert_equal(result.files.size, 1)
    assert_equal(result.files.first.identifier, "file__xid-1234_1.txt")
  end

  it "matches_xid? method returns the correct results" do
    assert_equal(@file.matches_xid?("xid-1234_1"), true)
    assert_equal(@file.matches_xid?("xid-5678_1"), false)
  end
end
