require "senkyoshi/models/root_resource"
require "senkyoshi/models/content_file"

module Senkyoshi
  class Content < RootResource
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

    attr_accessor(:title, :body, :files, :url)
    attr_reader(:extendeddata)

    def initialize(resource_id = nil)
      super(resource_id)
    end

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

      ## TODO why is this happening? How necessary is it?
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
      module_item = ModuleItem.new(@title, @module_type, @id, @url)
      module_item.canvas_conversion
    end

    def self.get_pre_data(xml, file_name)
      parent_id = xml.xpath("/CONTENT/PARENTID/@value").first.text
      {
        id: file_name,
        parent_id: parent_id,
        file_name: file_name,
      }
    end

    def canvas_conversion(course, _resources = nil)
      course
    end

    def create_module(course)
      course.canvas_modules ||= []
      cc_module = course.canvas_modules.
        detect { |a| a.identifier == @parent_id }
      if cc_module
        cc_module.module_items << @module_item
      else
        title = @parent_title || @title
        cc_module = Module.new(title, @parent_id)
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
        course.canvas_modules << cc_module
      end
      course
    end
  end
end
