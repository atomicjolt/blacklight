require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../../lib/senkyoshi/models/attachment"

describe "Attachment" do
  it "creates module_item" do
    xml = get_fixture_xml "attachment.xml"
    attachment = Senkyoshi::Attachment.new
    result = attachment.iterate_xml(xml, {})
    result_module = result.instance_variable_get("@module_item")

    assert_equal(result_module.content_type, "Attachment")
    assert_equal(result_module.title, "IP-135")
  end

  it "implements canvas_conversion" do
    xml = get_fixture_xml "attachment.xml"
    course = CanvasCc::CanvasCC::Models::Course.new
    attachment = Senkyoshi::Attachment.new
    attachment.iterate_xml(xml, {})

    result = attachment.canvas_conversion(course, nil)
    assert_equal(result.canvas_modules.size, 1)
    assert_equal(result.canvas_modules.first.title, MASTER_MODULE)
  end
end
