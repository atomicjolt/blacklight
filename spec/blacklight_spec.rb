require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "open_file" do
    it "should return with an error" do
      file_path = File.expand_path("../fixtures/", __FILE__) + "/test.zip"
      err = assert_raises(Exception) { Blacklight.open_file(file_path, "") }
      assert_match /Couldn't find file/, err.message
    end
  end
end
