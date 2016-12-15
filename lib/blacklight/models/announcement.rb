module Blacklight
  class Announcement
    def initialize
      @title = ""
      @text = ""
      @delayed_post = ""
      @posted_at = ""
      @identifier = Blacklight.create_random_hex
      @dependency = Blacklight.create_random_hex
      @type = "announcement"
    end

    def iterate_xml(data, pre_data)
      dates = data.children.at("DATES")
      @title = Blacklight.get_attribute_value(data, "TITLE")
      @text = Blacklight.get_text(data, "TEXT")
      @delayed_post = Blacklight.get_attribute_value(dates, "RESTRICTSTART")
      @posted_at = Blacklight.get_attribute_value(dates, "CREATED")
      self
    end

    def canvas_conversion(course)
      announcement = CanvasCc::CanvasCC::Models::Announcement.new
      announcement.title = @title
      announcement.text = @text
      announcement.delayed_post = @delayed_post
      announcement.posted_at = @posted_at
      announcement.identifier = @identifier
      announcement.dependency = @dependency
      course.announcements << announcement
      course
    end
  end
end
