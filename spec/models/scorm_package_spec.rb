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
    get_zip_manifest("scorm_package.zip") do |zip, manifest|
      result = Blacklight::ScormPackage.get_entries(zip, manifest)
      assert_equal(result.size, 2)
      assert_equal(
        manifest.get_input_stream.read.include?("ADL SCORM"),
        true,
      )
    end
  end

  it "should convert to zip file" do
    get_zip_manifest("scorm_package.zip") do |zip, manifest|
      package = Blacklight::ScormPackage.new(zip, manifest)
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
        Blacklight::ScormPackage.cleanup # Remove temp files
      end
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
