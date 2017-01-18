require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../mocks/mockzip"

include Senkyoshi

describe Senkyoshi do
  describe "Resource" do
    before do
      @resource = Resource.new
      @contents = get_fixture("embedded_images.txt") do |file|
        CGI.unescapeHTML(file.read)
      end
    end

    describe "fix_html" do
      # will set to directory base because files don't actually exist
      base = "%24CANVAS_COURSE_REFERENCE%24/files/folder"
      before do
        path = "fake/path/to/image123__xid-123_1.jpg"
        entry = MockZip::MockEntry.new(path)
        @file1 = Senkyoshi::SenkyoshiFile.new(entry)

        path = "fake/path/to/image456__xid-456_1.jpg"
        entry = MockZip::MockEntry.new(path)
        @file2 = Senkyoshi::SenkyoshiFile.new(entry)

        path = "fake/path/to/pdf789__xid-802_2.pdf"
        entry = MockZip::MockEntry.new(path)
        @file3 = Senkyoshi::SenkyoshiFile.new(entry)

        path = "fake/path/to/image987__xid-801_2.jpg"
        entry = MockZip::MockEntry.new(path)
        @file4 = Senkyoshi::SenkyoshiFile.new(entry)

        path = "fake/path/to/directory__xid-345_1"
        entry = MockZip::MockEntry.new(path)
        @file5 = Senkyoshi::SenkyoshiFile.new(entry)

        path = "file1__xid-567_1.txt"
        entry = MockZip::MockEntry.new(path)
        @file6 = Senkyoshi::SenkyoshiFile.new(entry)

        @resources = Senkyoshi::Collection.new
      end

      it "fixes the src attribute for image tags" do
        @resources.add([@file1])

        results = @resource.fix_html(@contents, @resources)

        expected_results = "#{base}/fake/path/to/image123.jpg"
        assert_includes(results, expected_results)
      end

      it "works correctly with multiple image tags" do
        @resources.add([@file1, @file2])

        results = @resource.fix_html(@contents, @resources)
        correct_result_one = "#{base}/fake/path/to/image123.jpg"
        correct_result_two = "#{base}/fake/path/to/image456.jpg"

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

        href = "#{base}/fake/path/to/pdf789.pdf"
        src = "#{base}/fake/path/to/image987.jpg"

        assert_includes(results, href)
        assert_includes(results, src)
      end

      it "fixes the src attribute for directory links" do
        @contents = get_fixture("embedded_links.txt") do |file|
          CGI.unescapeHTML(file.read)
        end
        @resources.add([@file5])

        results = @resource.fix_html(@contents, @resources)

        expected_results = "#{base}/fake/path/to/directory"
        assert_includes(results, expected_results)
      end

      it "fixes the src attribute for link to actual file" do
        @contents = get_fixture("embedded_links.txt") do |file|
          CGI.unescapeHTML(file.read)
        end
        @resources.add([@file6])
        dir = "#{Dir.pwd}/spec/fixtures/file1__xid-567_1.txt"
        @resources.resources.first.location = dir
        results = @resource.fix_html(@contents, @resources)

        expected_results = "%24IMS-CC-FILEBASE%24/file1.txt"
        assert_includes(results, expected_results)
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
