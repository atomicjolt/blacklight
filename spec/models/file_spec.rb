require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../mocks/mockzip"
require_relative "../../lib/senkyoshi/models/file"

describe "SenkyoshiFile" do
  before do
    @path = "fake/path/to/file__xid-1234_1.txt"
    entry = MockZip::MockEntry.new(@path)
    @file = Senkyoshi::SenkyoshiFile.new(entry)
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

  it "should determine if file is blacklisted" do
    mock_entries = [
      MockZip::MockEntry.new("test.jpg"),
      MockZip::MockEntry.new("test.dat"),
    ]

    result = mock_entries.map { |entry| SenkyoshiFile.blacklisted?(entry) }
    assert_equal(result[0], false)
    assert_equal(result[1], true)
  end

  it "should determine if a file is a metadata file" do
    mock_entries = [
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.xml"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.xml.xml"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-12.jpg.xml"),
    ]

    file_names = mock_entries.map(&:name).sort
    result = mock_entries.map do |entry|
      SenkyoshiFile.metadata_file?(file_names, entry)
    end

    expected_result = [false, true, false, true]

    assert_equal(expected_result, result)
  end

  it "should determine if a file belongs to a scorm package" do
    package_paths = ["abc/def", "ghi"]
    mock_entries = [
      MockZip::MockEntry.new("abc/def/scorm.txt"),
      MockZip::MockEntry.new("abc/not_scorm.txt"),
      MockZip::MockEntry.new("also_not_scorm.txt"),
      MockZip::MockEntry.new("ghi/is_scorm.txt"),
    ]

    expected_result = [true, false, false, true]
    result = mock_entries.map do |entry|
      SenkyoshiFile.belongs_to_scorm_package? package_paths, entry
    end

    assert_equal(expected_result, result)
  end
end
