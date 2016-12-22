require "minitest/autorun"

require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../mocks/mockzip"

include Blacklight

describe Blacklight do
  describe "Resource" do
    before do
      @resource = Resource.new
      @contents = get_fixture("embedded_images.txt") do |file|
        CGI.unescapeHTML(file.read)
      end
    end

    describe "fix_html" do
      before do
        path = "fake/path/to/image123__xid-123_1.jpg"
        entry = MockZip::MockEntry.new(path)
        @file1 = Blacklight::BlacklightFile.new(entry)

        path = "fake/path/to/image456__xid-456_1.jpg"
        entry = MockZip::MockEntry.new(path)
        @file2 = Blacklight::BlacklightFile.new(entry)

        path = "fake/path/to/pdf789__xid-802_2.pdf"
        entry = MockZip::MockEntry.new(path)
        @file3 = Blacklight::BlacklightFile.new(entry)

        path = "fake/path/to/image987__xid-801_2.jpg"
        entry = MockZip::MockEntry.new(path)
        @file4 = Blacklight::BlacklightFile.new(entry)

        @resources = Blacklight::Collection.new
      end

      it "fixes the src attribute for image tags" do
        @resources.add([@file1])

        results = @resource.fix_html(@contents, @resources)

        assert_includes(results, "%24IMS-CC-FILEBASE%24/Imported/image123.jpg")
      end

      it "works correctly with multiple image tags" do
        @resources.add([@file1, @file2])

        results = @resource.fix_html(@contents, @resources)
        correct_result_one = "%24IMS-CC-FILEBASE%24/Imported/image123.jpg"
        correct_result_two = "%24IMS-CC-FILEBASE%24/Imported/image456.jpg"

        assert_includes(results, correct_result_one)
        assert_includes(results, correct_result_two)
      end

      it "leaves the src attribute alone if no matching file is found" do
        results = @resource.fix_html(@contents, @resources)

        correct_result_one = "requestUrlStub@X@bbcswebdav/xid-123_1"
        correct_result_two = "requestUrlStub@X@bbcswebdav/xid-456_1"

        assert_includes(results, correct_result_one)
        assert_includes(results, correct_result_two)
      end

      it "fixes href for a tags and src for img tags" do
        @contents = get_fixture("embedded_a_tag_image.txt") do |file|
          CGI.unescapeHTML(file.read)
        end

        @resources.add([@file3, @file4])

        results = @resource.fix_html(@contents, @resources)

        href = "%24IMS-CC-FILEBASE%24/#{IMPORTED_FILES_DIRNAME}/pdf789.pdf"
        src = "%24IMS-CC-FILEBASE%24/#{IMPORTED_FILES_DIRNAME}/image987.jpg"

        assert_includes(results, href)
        assert_includes(results, src)
      end
    end

    describe "matches_xid? default implementation" do
      it "returns false" do
        resource = Resource.new

        assert_equal(resource.matches_xid?("1234"), false)
      end
    end
  end
end
