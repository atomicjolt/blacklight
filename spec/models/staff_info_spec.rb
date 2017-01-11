require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../mocks/mockzip"
require_relative "../../lib/senkyoshi/models/staff_info"

describe "StaffInfo" do
  def setup
    @resources = Senkyoshi::Collection.new
  end

  it "should parse xml" do
    xml = get_fixture_xml("staff_info_1.xml")
    bio = "Contact this office for asistance."
    name = "Mr. Test Name"
    office_hours = "24/7"
    office_address = "123 Fake St."
    home_page = "example.com"
    image = "example.com/image.png"

    staff_info = StaffInfo.new.iterate_xml(xml, nil)

    assert_equal(staff_info.id, "_112170_1")
    assert_equal(staff_info.title, "Test Title")

    assert_includes(staff_info.entries.first, bio)
    assert_includes(staff_info.entries.first, name)
    assert_includes(staff_info.entries.first, office_hours)
    assert_includes(staff_info.entries.first, office_address)
    assert_includes(staff_info.entries.first, home_page)
    assert_includes(staff_info.entries.first, image)
  end

  it "should convert to a single canvas page" do
    course = CanvasCc::CanvasCC::Models::Course.new

    staff_info = StaffInfo.new
    staff_info.iterate_xml(get_fixture_xml("staff_info_1.xml"), nil)
    staff_info.iterate_xml(get_fixture_xml("staff_info_2.xml"), nil)
    staff_info.canvas_conversion course, @resources

    assert_equal(course.pages.size, 1)
    assert_equal(course.pages.first.body.include?("Mr. Test Name"), true)
    assert_equal(course.pages.first.body.include?("Ms. Spec Test"), true)
  end
end
