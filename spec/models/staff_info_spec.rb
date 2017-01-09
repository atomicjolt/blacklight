require "minitest/autorun"
require "senkyoshi"
require "pry"

require_relative "../mocks/mockzip"
require_relative "../../lib/senkyoshi/models/staff_info"

describe "StaffInfo" do
  def setup
    StaffInfo.reset_entries

    @resources = Senkyoshi::Collection.new
  end

  it "should parse xml" do
    xml = get_fixture_xml("staff_info_1.xml")
    staff_info = StaffInfo.new.iterate_xml(xml, nil)

    assert_equal(staff_info.id, "_112170_1")
    assert_equal(staff_info.title, "Test Title")
    assert_equal(
      staff_info.bio.include?("Contact this office for asistance."),
      true,
    )
    assert_equal(staff_info.name, "Mr. Test Name")
    assert_equal(staff_info.office_hours, "24/7")
    assert_equal(staff_info.office_address, "123 Fake St.")
    assert_equal(staff_info.home_page, "example.com")
    assert_equal(staff_info.image, "example.com/image.png")
  end

  it "should convert to a single canvas page" do
    course = CanvasCc::CanvasCC::Models::Course.new
    results = [
      StaffInfo.new.iterate_xml(get_fixture_xml("staff_info_1.xml"), nil),
      StaffInfo.new.iterate_xml(get_fixture_xml("staff_info_2.xml"), nil),
    ]
    results.each { |staff| staff.canvas_conversion course, @resources }

    assert_equal(course.pages.size, 1)
    assert_equal(course.pages.first.body.include?("Mr. Test Name"), true)
    assert_equal(course.pages.first.body.include?("Ms. Spec Test"), true)
  end
end
