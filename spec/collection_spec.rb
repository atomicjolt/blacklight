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
      it "should detect the resources with matching xid" do
        xid = "xid-1234_1"
        path = "fake/path/to/file__#{xid}.txt"
        entry = MockZip::MockEntry.new(path)
        file = Blacklight::BlacklightFile.new(entry)
        resource = Blacklight::Resource.new
        @collection.add([file, resource])
        assert_equal(@collection.detect_xid(xid), file)
      end
    end
  end
end
