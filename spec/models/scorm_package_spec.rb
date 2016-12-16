require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../../lib/blacklight/models/scorm_package"

def get_manifest_entry(zip)
  zip.entries.detect do |i|
    File.fnmatch? "*imsmanifest.xml", i.name
  end
end

describe "ScormPackage" do
  it "should find all entries in same directory as manifest" do
    zip = Zip::File.new("spec/fixtures/scorm_package.zip")
    manifest = get_manifest_entry zip

    result = Blacklight::ScormPackage.get_entries(zip, manifest)
    assert_equal(result.size, 2)
    assert_equal(
      manifest.get_input_stream.read.include?("ADL SCORM"),
      true,
    )
  end

  it "should convert to zip file" do
    zip = Zip::File.new("spec/fixtures/scorm_package.zip")
    package = Blacklight::ScormPackage.new(zip, get_manifest_entry(zip))
    EXPORT_NAME = "zip_export.zip".freeze
    begin
      result_location = package.write_zip(EXPORT_NAME)
      result_zip = Zip::File.new(result_location)
      result_manifest = get_manifest_entry(result_zip)

      assert_equal(
        result_manifest.get_input_stream.read.include?("ADL SCORM"),
        true,
      )
    ensure
      Blacklight::ScormPackage.cleanup # Remove temp files
    end
  end

  it "should correct paths in scorm package" do
    nested_path = "fake/nested/directory"
    assert_equal(
      Blacklight::ScormPackage.correct_path(
        "#{nested_path}/test.jpg", nested_path
      ),
      "test.jpg",
    )

    assert_equal(
      Blacklight::ScormPackage.correct_path(
        "#{nested_path}/nested/test.jpg", nested_path
      ),
      "nested/test.jpg",
    )
  end
end
