require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "read_file" do
    it "should return with an error" do
      file_path = File.expand_path("../fixtures/", __FILE__) + "/test.zip"
      err = assert_raises(Exception) { Senkyoshi.read_file(file_path, "") }
      assert_match /Couldn't find file/, err.message
    end
  end
end
