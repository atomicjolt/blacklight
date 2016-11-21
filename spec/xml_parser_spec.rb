require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "create_random_hex" do
    it "should return a random string" do
      assert_equal Blacklight.create_random_hex.length, 32
    end
  end

  describe "iterate_course" do
    it "should " do
    end
  end
end
