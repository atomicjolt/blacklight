require "fileutils"
require "securerandom"
require_relative "exceptions"

module Blacklight
  def self.iterate_course(xml_data, course)
    course.set_values("identifier", xml_data["id"])
    course.set_values("title", get_attribute_value(xml_data, "TITLE"))
    course.set_values("description", get_description(xml_data))
    course.set_values("is_public", get_attribute_value(xml_data, "ISAVAILABLE"))
    course.set_values("start_at", get_attribute_value(xml_data, "COURSESTART"))
    course.set_values("conclude_at", get_attribute_value(xml_data, "COURSEEND"))
  end

  def self.iterate_announcement(xml_data, course)
    dates = xml_data.children.at("DATES")
    announcement = CanvasCc::CanvasCC::Models::Announcement.new
    announcement.text = get_text(xml_data, "TEXT")
    announcement.title = get_attribute_value(xml_data, "TITLE")
    announcement.delayed_post = get_attribute_value(dates, "RESTRICTSTART")
    announcement.posted_at = get_attribute_value(dates, "CREATED")
    announcement.identifier = create_random_hex
    announcement.dependency = create_random_hex
    course.add_resource("announcements", announcement)
  end

  def self.iterate_forum(xml_data, course)
    forum = CanvasCc::CanvasCC::Models::Discussion.new
    forum.identifier = create_random_hex
    forum.title = get_attribute_value(xml_data, "TITLE")
    forum.text = get_text(xml_data, "TEXT")
    forum.discussion_type = "threaded"
    course.add_resource("discussions", forum)
  end
end
