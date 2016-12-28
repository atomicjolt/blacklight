require "minitest/autorun"
require "senkyoshi/canvas_course"
require_relative "helpers/spec_helper"

include Senkyoshi

describe Senkyoshi::CanvasCourse do
  describe "metadata_from_file" do
    it "should return metadata" do
      file = fixture_finder("bfcoding-101-export.imscc")
      metadata = Senkyoshi::CanvasCourse.metadata_from_file(file)
      assert_equal metadata, name: "bfcoding 101"
    end
  end

  describe "from_metadata" do
    it "should return a canvas course" do
      name = "bfcoding 101"
      stub_active_courses_in_account([{ name: name }])
      metadata = { name: name }
      course = Senkyoshi::CanvasCourse.from_metadata(metadata)
      assert_kind_of Senkyoshi::CanvasCourse, course
    end
  end
end
