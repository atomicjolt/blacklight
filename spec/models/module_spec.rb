require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/blacklight/models/module"

describe "Module" do
  before do
    @title = "Module Name"
    @identifier = Blacklight.create_random_hex
    @module = Blacklight::Module.new(@title, @identifier)
  end

  describe "initialize" do
    it "should initialize module" do
      assert_equal (@module.is_a? Object), true
      assert_equal (@module.instance_variable_get :@title), @title
      assert_equal (@module.instance_variable_get :@identifier), @identifier
    end
  end

  it "should convert to canvas wiki page" do
    result = @module.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.identifier, @identifier)
    assert_equal(result.module_items.count, 0)
  end

  it "should convert to canvas wiki page" do
    title = "Module Item Name"
    content_type = "Assignment"
    identifierref = Blacklight.create_random_hex
    module_item = Blacklight::ModuleItem.new(@title, @content_type, @identifierref)

    @module.module_items << module_item
    result = @module.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.identifier, @identifier)
    assert_equal(result.module_items.count, 1)
  end
end
