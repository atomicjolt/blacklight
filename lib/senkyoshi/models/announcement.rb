require "senkyoshi/models/resource"

module Senkyoshi
  class Announcement < Resource
    def initialize
      @title = ""
      @text = ""
      @delayed_post = ""
      @posted_at = ""
      @identifier = Senkyoshi.create_random_hex
      @dependency = Senkyoshi.create_random_hex
      @type = "announcement"
    end

    def iterate_xml(data, _)
      dates = data.children.at("DATES")
      @title = Senkyoshi.get_attribute_value(data, "TITLE")
      @text = Senkyoshi.get_text(data, "TEXT")
      @delayed_post = Senkyoshi.get_attribute_value(dates, "RESTRICTSTART")
      @posted_at = Senkyoshi.get_attribute_value(dates, "CREATED")
      self
    end

    def canvas_conversion(course, resources)
      announcement = CanvasCc::CanvasCC::Models::Announcement.new
      announcement.title = @title
      announcement.text = fix_html(@text, resources)
      announcement.delayed_post = @delayed_post
      announcement.posted_at = @posted_at
      announcement.identifier = @identifier
      announcement.dependency = @dependency
      course.announcements << announcement
      course
    end
  end
end
