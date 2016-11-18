require 'fileutils'
require 'securerandom'
require_relative 'exceptions'

module Blacklight

	def self.iterate_announcement(xml_data, course)
		announcement = CanvasCc::CanvasCC::Models::Announcement.new
		announcement.text = get_text(xml_data)
		announcement.title = get_title(xml_data)
		announcement.delayed_post = xml_data.children.at('DATES').children.at('RESTRICTSTART').attributes["value"].value
		announcement.posted_at = xml_data.children.at('DATES').children.at('CREATED').attributes["value"].value
		announcement.identifier = create_random_hex
		announcement.dependency = create_random_hex
		course.add_resource('announcements', announcement)
  end

  def self.iterate_forum(xml_data, course)
  	forum = CanvasCc::CanvasCC::Models::Discussion.new
  	forum.identifier = create_random_hex
  	forum.title = get_title(xml_data)
  	forum.text = get_text(xml_data)
  	forum.discussion_type = 'threaded'
  	course.add_resource('discussions', forum)
  end

  def self.create_random_hex
  	'i' + SecureRandom.hex
  end

  def self.get_title(xml_data)
  	xml_data.children.at('TITLE').attributes["value"].value
  end

  def self.get_text(xml_data)
  	xml_data.children.at('DESCRIPTION').children.at('TEXT').text
  end


end