require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do

  describe "#directory_exists?" do
    it "should not exist" do
      pathname = "/path/to/dir"
      assert_equal Blacklight.directory_exists?(pathname), false
    end

    it "should exist" do
      pathname = "spec"
      assert_equal Blacklight.directory_exists?(pathname), true
    end
  end

  describe "#set_correct_dir_location" do
    it "should return file ending in /" do
      pathname = "/path/to/dir"
      assert_equal Blacklight.set_correct_dir_location(pathname), pathname + "/"
    end

    it "should return file ending in /" do
      pathname = "/path/to/dir/"
      assert_equal Blacklight.set_correct_dir_location(pathname), pathname
    end
  end

  describe "#opens_dir" do
    it "should not exist" do
      source_dir = "/path/to/dir/source"
      output_dir = "/path/to/dir/output"
      assert_equal Blacklight.opens_dir(source_dir, output_dir), nil
    end
  end
end
