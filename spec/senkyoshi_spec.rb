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

  describe ".reset" do
    it "resets the configuration" do
      Configuration.stub(:_config, {}) do
        Senkyoshi.configure do |config|
          config.canvas_url = "bfcoder.com"
          config.canvas_token = "token"
          config.account_id = 42
          config.scorm_url = "example.com"
          config.scorm_launch_url = "example.com/launch"
          config.scorm_shared_auth = "12345"
        end
        Senkyoshi.reset
        config = Senkyoshi.configuration
        assert_nil config.canvas_url
        assert_nil config.canvas_token
        assert_equal config.account_id, :self
        assert_nil config.scorm_url
        assert_nil config.scorm_launch_url
        assert_nil config.scorm_shared_auth
      end
    end
  end

  describe ".configure" do
    it "sets the configuration" do
      Configuration.stub(:_config, {}) do
        Senkyoshi.configure do |config|
          config.canvas_url = "bfcoder.com"
          config.canvas_token = "token"
          config.account_id = 42
          config.scorm_url = "example.com"
          config.scorm_launch_url = "example.com/launch"
          config.scorm_shared_auth = "12345"
        end
        config = Senkyoshi.configuration
        assert_equal config.canvas_url, "bfcoder.com"
        assert_equal config.canvas_token, "token"
        assert_equal config.account_id, 42
        assert_equal config.scorm_url, "example.com"
        assert_equal config.scorm_launch_url, "example.com/launch"
        assert_equal config.scorm_shared_auth, "12345"
      end
    end
  end
end
