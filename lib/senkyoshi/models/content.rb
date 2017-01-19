require "senkyoshi/models/resource"
require "senkyoshi/models/content_file"

module Senkyoshi
  class Content < Resource
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
    }.freeze

    MODULE_TYPES = {
      "Senkyoshi::Attachment" => "Attachment",
      "Senkyoshi::Assignment" => "Assignment",
      "Senkyoshi::ExternalUrl" => "ExternalUrl",
      "Senkyoshi::WikiPage" => "WikiPage",
      "Senkyoshi::Quiz" => "Quizzes::Quiz",
    }.freeze

    attr_accessor(:title, :body, :id, :files, :url)
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
        content = content_class.new
        content.iterate_xml(xml, pre_data)
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
      @id = xml.xpath("/CONTENT/@id").first.text
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
      module_item = ModuleItem.new(@title, @module_type, @id, @url, @indent, @file_name)
      module_item.canvas_conversion
    end

    def canvas_conversion(course, _resources = nil)
      course
    end

    def create_module(course)
      course.canvas_modules ||= []
      cc_module = course.canvas_modules.
        detect { |a| a.title == 'master_module' }
      if cc_module
        cc_module.module_items << @module_item
      else
        cc_module = Module.new('master_module', "master_module")
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
        course.canvas_modules << cc_module
      end
      course
    end
  end
end
