# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "senkyoshi/models/file_resource"
require "senkyoshi/models/content_file"

module Senkyoshi
  class Content < FileResource
    CONTENT_TYPES = {
      "x-bb-asmt-test-link" => "Quiz",
      "x-bb-asmt-survey-link" => "Quiz",
      "x-bb-assignment" => "Assignment",
      "x-bbpi-selfpeer-type1" => "Assignment",
      "x-bb-document" => "WikiPage",
      "x-bb-file" => "Attachment",
      "x-bb-audio" => "Attachment",
      "x-bb-image" => "Attachment",
      "x-bb-video" => "Attachment",
      "x-bb-externallink" => "ExternalUrl",
      "x-bb-blankpage" => "WikiPage",
      "x-bb-lesson" => "WikiPage",
      "x-bb-folder" => "WikiPage",
      "x-bb-module-page" => "WikiPage",
      "x-bb-lesson-plan" => "WikiPage",
      "x-bb-syllabus" => "WikiPage",
      "x-bb-courselink" => "WikiPage",
    }.freeze

    MODULE_TYPES = {
      "Senkyoshi::Attachment" => "Attachment",
      "Senkyoshi::Assignment" => "Assignment",
      "Senkyoshi::ExternalUrl" => "ExternalUrl",
      "Senkyoshi::WikiPage" => "WikiPage",
      "Senkyoshi::Quiz" => "Quizzes::Quiz",
    }.freeze

    attr_accessor(:title, :body, :files, :url)
    attr_reader(:extendeddata)

    def self.from(xml, pre_data, resource_xids)
      type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      type.slice! "resource/"

      xml.xpath("//FILES/FILE").each do |file|
        file_name = ContentFile.clean_xid file.at("NAME").text
        is_attachment = CONTENT_TYPES[type] == "Attachment"
        if !resource_xids.include?(file_name) && is_attachment
          type = "x-bb-document"
          break
        end
      end

      if content_type = CONTENT_TYPES[type]
        content_class = Senkyoshi.const_get content_type
        content_class.new(pre_data[:file_name]).iterate_xml(xml, pre_data)
      end
    end

    def iterate_xml(xml, pre_data)
      @points = pre_data[:points] || 0
      @parent_title = pre_data[:parent_title]
      @indent = pre_data[:indent]
      @file_name = pre_data[:file_name]
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @url = xml.at("URL")["value"]
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @extendeddata = xml.at("/CONTENT/EXTENDEDDATA/ENTRY")
      if @extendeddata
        @extendeddata = @extendeddata.text
      end
      @type = xml.xpath("/CONTENT/RENDERTYPE/@value").first.text
      @parent_id = pre_data[:parent_id]
      @module_type = MODULE_TYPES[self.class.name]
      @referred_to_title = pre_data[:referred_to_title]

      if pre_data[:assignment_id] && !pre_data[:assignment_id].empty?
        @id = pre_data[:assignment_id]
      end

      @files = xml.xpath("//FILES/FILE").map do |file|
        ContentFile.new(file)
      end
      @module_item = set_module if @module_type
      self
    end

    def set_module
      ModuleItem.new(
        @title,
        @module_type,
        @id,
        @url,
        @indent,
        @file_name,
      ).canvas_conversion
    end

    def canvas_conversion(course, _resources = nil)
      course
    end

    def create_module(course)
      super(course)
    end
  end
end
