require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../../lib/blacklight/models/file"

describe "Content" do
  it "should iterate_xml" do
    path = "fake/path/to/file__xid-1234.txt"
    file = Blacklight::BlacklightFile.new(path)

    assert_equal(file.id, "xid-1234")
    assert_equal(file.name, File.basename(path))
    assert_equal(file.location, path)
  end

  it "should convert to canvas file " do
    path = "fake/path/to/file__xid-1234.txt"
    file = Blacklight::BlacklightFile.new(path)
    course = CanvasCc::CanvasCC::Models::Course.new

    result = file.canvas_conversion(course)

    assert_equal(result.files.size, 1)
    assert_equal(result.files.first.identifier, "xid-1234")
  end
end
