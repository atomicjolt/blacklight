require 'fileutils'
require 'securerandom'
require_relative 'exceptions'

module Blacklight

	def self.iterate_announcement(xml_data, course)
		announcement = CanvasCc::CanvasCC::Models::Announcement.new
		announcement.text = xml_data.children.at('DESCRIPTION').children.at('TEXT').text
		announcement.title = xml_data.children.at('TITLE').attributes["value"].value
		announcement.delayed_post = xml_data.children.at('DATES').children.at('RESTRICTSTART').attributes["value"].value
		announcement.posted_at = xml_data.children.at('DATES').children.at('CREATED').attributes["value"].value
		announcement.identifier = 'i' + SecureRandom.hex
		announcement.dependency = 'i' + SecureRandom.hex
		course.add_resource('announcements', announcement)
  end

  def self.iterate_forum(xml_data, course)

  end


end