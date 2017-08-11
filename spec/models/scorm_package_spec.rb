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

require_relative "../../lib/senkyoshi/models/scorm_package"

def get_manifest_entry(zip)
  zip.entries.detect do |i|
    File.fnmatch? "*imsmanifest.xml", i.name
  end
end

describe "ScormPackage" do
  it "should find all entries in same directory as manifest" do
    get_zip_manifest("scorm_package.zip") do |zip, manifest|
      result = Senkyoshi::ScormPackage.get_entries(zip, manifest)
      assert_equal(result.size, 2)
      assert_equal(
        manifest.get_input_stream.read.include?("ADL SCORM"),
        true,
      )
    end
  end

  it "should convert to zip file" do
    get_zip_manifest("scorm_package.zip") do |zip, manifest|
      package = Senkyoshi::ScormPackage.new(zip, manifest)
      EXPORT_NAME = "zip_export.zip".freeze
      begin
        result_location = package.write_zip(EXPORT_NAME)
        Zip::File.open(result_location) do |file|
          result_manifest = get_manifest_entry(file)

          assert_equal(
            result_manifest.get_input_stream.read.include?("ADL SCORM"),
            true,
          )
        end
      ensure
        package.cleanup # Remove temp files
      end
    end
  end

  it "should correct paths in scorm package" do
    nested_path = "fake/nested/directory"
    assert_equal(
      Senkyoshi::ScormPackage.correct_path(
        "#{nested_path}/test.jpg", nested_path
      ),
      "test.jpg",
    )

    assert_equal(
      Senkyoshi::ScormPackage.correct_path(
        "#{nested_path}/nested/test.jpg", nested_path
      ),
      "nested/test.jpg",
    )
  end
end
