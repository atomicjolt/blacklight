module Blacklight
  class Content
    CONTENT_TYPES = {
      "x-bb-asmt-test-link" => "Quiz",
      "x-bb-asmt-survey-link" => "Quiz",
      "x-bb-assignment" => "Assignment",
      "x-bbpi-selfpeer-type1" => "Assignment",
      "x-bb-document" => "WikiPage",
      "x-bb-file" => "WikiPage",
      "x-bb-audio" => "WikiPage",
      "x-bb-image" => "WikiPage",
      "x-bb-video" => "WikiPage",
      "x-bb-externallink" => "WikiPage",
      "x-bb-blankpage" => "WikiPage",
      "x-bb-lesson" => "WikiPage",
      "x-bb-folder" => "WikiPage",
      "x-bb-module-page" => "WikiPage",
      "x-bb-lesson-plan" => "WikiPage",
      "x-bb-syllabus" => "WikiPage",
    }.freeze

    attr_accessor(:title, :body, :id, :files)

    def self.from(xml, pre_data)
      type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      type.slice! "resource/"
      if content_type = CONTENT_TYPES[type]
        content_class = Blacklight.const_get content_type
        content = content_class.new
        content.iterate_xml(xml, pre_data)
      end
    end

    def iterate_xml(xml, pre_data)
      @points = pre_data[:points] || 0
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @type = xml.xpath("/CONTENT/RENDERTYPE/@value").first.text
      @parent_id = pre_data[:parent_id]
      bb_type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      bb_type.slice! "resource/"
      @module_type = CONTENT_TYPES[bb_type]
      @id = xml.xpath("/CONTENT/@id").first.text
      if pre_data[:assignment_id] && !pre_data[:assignment_id].empty?
        @id = pre_data[:assignment_id]
      end
      @module_item = set_module if @module_type
      @files = xml.xpath("//FILES/FILE").map do |file|
        ContentFile.new(file)
      end
      self
    end

    def get_pre_data(xml, file_name)
      id = xml.xpath("/CONTENT/@id").first.text
      parent_id = xml.xpath("/CONTENT/PARENTID/@value").first.text
      {
        id: id,
        parent_id: parent_id,
        file_name: file_name
      }
    end

    def set_module
      @module_type = "Quizzes::Quiz" if @module_type == "Quiz"
      module_item = ModuleItem.new(@title, @module_type, @id)
      module_item.canvas_conversion
    end

    def canvas_conversion(course)
      course
    end

    def create_module(course)
      course.canvas_modules ||= []
      cc_module = course.canvas_modules.
        detect { |a| a.identifier == @parent_id }
      if cc_module
        cc_module.module_items << @module_item
      else
        cc_module = Module.new(@title, @parent_id)
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
        course.canvas_modules << cc_module
      end
      course
    end
  end
end
