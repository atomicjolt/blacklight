require "minitest/autorun"

require "blacklight"
require "pry"

require_relative "helpers.rb"
require_relative "mocks/mockzip"

include Blacklight

describe Blacklight do
  describe "Collection" do
    before do
      @collection = Blacklight::Collection.new
    end

    describe "initialize" do
      it "sets up an empty collection" do
        assert_equal(@collection.resources, [])
      end
    end

    describe "add" do
      it "adds resources to its collection" do
        @collection.add([Blacklight::Resource.new])
        assert_equal(@collection.resources.length, 1)

        @collection.add([Blacklight::Resource.new])
        assert_equal(@collection.resources.length, 2)
      end
    end

    describe "detect_xid" do

    end

    describe "each" do
      
    end
  end
end
