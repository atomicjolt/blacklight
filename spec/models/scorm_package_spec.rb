require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../../lib/blacklight/models/scorm_package"

def get_course_manifest(zip)
  zip.entries.detect do |i|
    i.name == "scorm_package/imsmanifest.xml"
  end
end

describe "ScormPackage" do
  it "should find all entries in same directory as manifest" do
    zip = Zip::File.new("spec/fixtures/scorm.zip")
    manifest = get_course_manifest zip

    result = Blacklight::ScormPackage.get_entries(zip, manifest)
    assert_equal(result.size, 308)
    assert_equal(
      manifest.get_input_stream.read.include?("ADL SCORM"),
      true,
    )
  end

  it "should convert to zip file" do
    zip = Zip::File.new("spec/fixtures/scorm.zip")
    package = Blacklight::ScormPackage.new(zip, get_course_manifest(zip))
    EXPORT_NAME = "zip_export.zip".freeze
    begin
      result = package.to_zip(EXPORT_NAME)
      result_manifest = get_course_manifest(result)

      assert_equal(result.entries.size, 308)
      assert_equal(
        result_manifest.get_input_stream.read.include?("ADL SCORM"),
        true,
      )
    ensure
      File.delete(EXPORT_NAME) if File.exist? EXPORT_NAME
    end
  end
end
