require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "directory_exists?" do
    it "should not exist" do
      pathname = "/path/to/dir"
      assert_equal Blacklight.directory_exists?(pathname), false
    end

    it "should exist" do
      pathname = "spec"
      assert_equal Blacklight.directory_exists?(pathname), true
    end
  end

  describe "set_correct_dir_location" do
    it "should return file ending in /" do
      pathname = "/path/to/dir"
      assert_equal Blacklight.set_correct_dir_location(pathname), pathname + "/"
    end

    it "should return file ending in /" do
      pathname = "/path/to/dir/"
      assert_equal Blacklight.set_correct_dir_location(pathname), pathname
    end
  end

  describe "opens_dir" do
    it "should not exist" do
      source_dir = "/path/to/dir/source"
      output_dir = "/path/to/dir/output"
      assert_nil Blacklight.opens_dir(source_dir, output_dir)
    end
  end

  describe "open_file" do
    it "should return with an error" do
      file_path = File.expand_path("../fixtures/", __FILE__) + "/test.zip"
      err = assert_raises(Exception) { Blacklight.open_file(file_path, "") }
      assert_match /Couldn't find file/, err.message
    end
  end

  describe "switch_file_name" do
    before do
      @file_name = "test"
      @file_path = File.expand_path("../fixtures/", __FILE__) +
        "/#{@file_name}.zip"
    end

    it "should switch out file name" do
      original_name = ""
      name = "/this_name.imscc"
      canvas_path = File.expand_path("../fixtures/", __FILE__) + name
      File.stub :rename, canvas_path do
        original_name = Blacklight.switch_file_name(canvas_path, @file_name)
      end
      assert_equal @file_path.gsub(".zip", ".imscc"), original_name
    end
  end
end
