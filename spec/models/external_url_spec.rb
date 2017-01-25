require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/external_url"

describe "ExternalUrl" do
  it "implements canvas_conversion" do
    xml = get_fixture_xml "external_url.xml"
    course = CanvasCc::CanvasCC::Models::Course.new
    external_url = Senkyoshi::ExternalUrl.new
    external_url.iterate_xml(xml, {})

    result = external_url.canvas_conversion(course, nil)
    assert_equal(result.canvas_modules.size, 1)
    c_module = result.canvas_modules.first

    assert_equal(c_module.title, MASTER_MODULE)
    assert_equal(c_module.module_items.first.url, "http://example.com")
  end
end
