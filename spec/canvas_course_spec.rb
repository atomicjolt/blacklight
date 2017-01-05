require "minitest/autorun"
require "senkyoshi/canvas_course"
require_relative "helpers/spec_helper"
require_relative "mocks/mock_client.rb"

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
      CanvasCourse.stub(:client, MockClient.new) do
        metadata = { name: name }
        course = Senkyoshi::CanvasCourse.from_metadata(metadata)
        assert_kind_of Senkyoshi::CanvasCourse, course
      end
    end
  end
end
