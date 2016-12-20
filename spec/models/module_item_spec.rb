require "minitest/autorun"
require "blacklight"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/blacklight/models/module_item"

describe "ModuleItem" do
  before do
    @title = "Module Item Name"
    @content_type = "Assignment"
    @identifierref = Blacklight.create_random_hex
    @module_item = Blacklight::ModuleItem.new(@title, @content_type,
                                              @identifierref)
  end

  describe "initialize" do
    it "should initialize module_item" do
      assert_equal (@module_item.is_a? Object), true
      assert_equal (@module_item.instance_variable_get :@title), @title
      assert_equal (@module_item.
        instance_variable_get :@identifierref), @identifierref
    end
  end

  it "should convert to canvas wiki page" do
    result = @module_item.canvas_conversion

    assert_equal(result.title, @title)
    assert_equal(result.content_type, @content_type)
    assert_equal(result.identifierref, @identifierref)
  end
end
