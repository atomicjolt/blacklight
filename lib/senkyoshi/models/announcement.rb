require "senkyoshi/models/file_resource"

module Senkyoshi
  class Announcement < FileResource
    def initialize(resource_id)
      super(resource_id)
      @title = ""
      @text = ""
      @delayed_post = ""
      @posted_at = ""
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
      announcement.identifier = @id
      announcement.dependency = @dependency
      course.announcements << announcement
      course
    end
  end
end
