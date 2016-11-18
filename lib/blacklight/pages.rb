require 'fileutils'
require 'securerandom'
require_relative 'exceptions'

module Blacklight

	def self.iterate_announcement(xml_data, course)
		title = xml_data.children.at('TITLE').attributes["value"].value
		text = xml_data.children.at('DESCRIPTION').children.at('TEXT').text
		posted_at = xml_data.children.at('DATES').children.at('CREATED').attributes["value"].value
		delayed_post = xml_data.children.at('DATES').children.at('RESTRICTSTART').attributes["value"].value
		identifier = 'i' + SecureRandom.hex
		File.open("announcements/#{identifier}.xml", "w") do |file|
			file.puts(<<-CONTENTS)
<?xml version="1.0" encoding="UTF-8"?>
<topic xmlns="http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd">
  <title>#{title}</title>
  <text texttype="text/html">#{CGI.escapeHTML(text)}</text>
</topic>
CONTENTS
		end

		dependency = 'i' + SecureRandom.hex
		File.open("announcements/#{dependency}.xml", "w") do |file|
			file.puts(<<-CONTENTS)
<?xml version="1.0" encoding="UTF-8"?>
<topicMeta identifier="#{dependency}" xmlns="http://canvas.instructure.com/xsd/cccv1p0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://canvas.instructure.com/xsd/cccv1p0 http://canvas.instructure.com/xsd/cccv1p0.xsd">
  <topic_id>#{identifier}</topic_id>
  <title>#{title}</title>
  <posted_at>#{posted_at}</posted_at>
  <delayed_post_at>#{delayed_post}</delayed_post_at>
  <position>1</position>
  <type>announcement</type>
  <discussion_type>side_comment</discussion_type>
  <has_group_category>false</has_group_category>
  <workflow_state>active</workflow_state>
  <module_locked>false</module_locked>
  <allow_rating/>
  <only_graders_can_rate/>
  <sort_by_rating/>
</topicMeta>
CONTENTS
		end

		announcement = CanvasCc::CanvasCC::Models::Announcement.new
		announcement.identifier = identifier
		announcement.dependency = dependency
		course.add_announcement(announcement)
  end

	def self.iterate_forum(xml_data, course)
  end

	def self.iterate_wiki(xml_data, course)
  end

  def self.iterate_conferences(xml_data, course)
  end

  def self.iterate_coursemodulepages(xml_data, course)
  end

end