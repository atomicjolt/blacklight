require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/gradebook"

describe "Gradebook" do
  before do
    @gradebook = Senkyoshi::Gradebook.new
  end

  describe "initialize" do
    it "should initialize gradebook" do
      assert_equal (@gradebook.is_a? Object), true
    end
  end

  describe "get_pre_data" do
    it "should get_pre_data and return an object" do
      xml = get_fixture_xml "gradebook.xml"
      pre_data = {}
      count = xml.search("OUTCOMEDEFINITIONS").children.length

      results = @gradebook.get_pre_data(xml, pre_data)
      assert_equal(results.length, count)
    end

    it "should get_pre_data and return an object" do
      xml = get_fixture_xml "gradebook.xml"
      pre_data = {}

      results = @gradebook.get_pre_data(xml, pre_data).first

      assert_equal results[:category], "Test"
      assert_equal results[:points], "50.0"
      assert_equal results[:content_id], "res00021"
      assert_equal results[:assignment_id], "res00014"
      assert_equal results[:due_at], ""
    end
  end

  describe "get_categories" do
    it "should get_categories and return categories" do
      xml = get_fixture_xml "gradebook.xml"
      count = xml.at("CATEGORIES").children.length

      categories = @gradebook.get_categories(xml)
      assert_equal(categories.length, count)
    end
  end
end
