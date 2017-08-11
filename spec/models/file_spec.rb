# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

  it "should force UTF-8 encoding for @xid and @path" do
    # ASCII encoding from zip_entry.
    zip_entry = get_zip_fixture("empty_dat.zip") { |zip| zip.entries.first }
    assert_equal("ASCII-8BIT", zip_entry.name.encoding.to_s)

    # UTF-8 encoding forced by SenkyoshiFile#initialize.
    file = Senkyoshi::SenkyoshiFile.new(zip_entry)
    assert_equal("UTF-8", file.xid.encoding.to_s)
    assert_equal("UTF-8", file.path.encoding.to_s)
  end

  it "should iterate_xml" do
    assert_equal(@file.xid, "xid-1234_1")
    assert_equal(@file.path, "fake/path/to/file.txt")
    assert_includes(@file.location, @path)
  end

  it "should convert to canvas file " do
    course = CanvasCc::CanvasCC::Models::Course.new

    result = @file.canvas_conversion(course)

    assert_equal(result.files.size, 1)
    assert_equal(result.files.first.identifier, "xid-1234_1")
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
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-23.jpg"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-23.jpg.xml"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-34"),
      MockZip::MockEntry.new("csfiles/home_dir/test__xid-34.xml"),
    ]

    file_names = mock_entries.map(&:name)
    dir_names = mock_entries.map { |entry| File.dirname(entry.name) }
    entry_names = dir_names + file_names

    result = mock_entries.map do |entry|
      SenkyoshiFile.metadata_file?(entry_names, entry)
    end

    expected_result = [false, true, false, true, false, true]

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
