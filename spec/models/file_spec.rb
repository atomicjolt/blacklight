require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../mocks/mockzip"
require_relative "../../lib/blacklight/models/file"

describe "BlacklightFile" do
  it "should iterate_xml" do
    path = "fake/path/to/file__xid-1234.txt"
    entry = MockZip::MockEntry.new(path)
    file = Blacklight::BlacklightFile.new(entry)

    assert_equal(file.id, "file__xid-1234.txt")
    assert_equal(file.name, File.basename(path))
    assert_includes(file.location, path)
  end

  it "should convert to canvas file " do
    path = "fake/path/to/file__xid-1234.txt"
    entry = MockZip::MockEntry.new(path)
    file = Blacklight::BlacklightFile.new(entry)
    course = CanvasCc::CanvasCC::Models::Course.new

    result = file.canvas_conversion(course)

    assert_equal(result.files.size, 1)
    assert_equal(result.files.first.identifier, "file__xid-1234.txt")
  end
end
