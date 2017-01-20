require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/module"

describe "Module" do
  before do
    @title = "Module Name"
    @identifier = Senkyoshi.create_random_hex
    @module = Senkyoshi::Module.new(@title, @identifier)
    @url = "fake/url"
    @indent = 0
    @id = "res00004"
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
    module_item = Senkyoshi::ModuleItem.new(
      @title,
      @content_type,
      @identifierref,
      @url,
      @indent,
      @id,
    )

    @module.module_items << module_item
    result = @module.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.identifier, @identifier)
    assert_equal(result.module_items.count, 1)
  end
end
