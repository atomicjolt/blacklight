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

      "x-bb-lesson" => "WikiPage-Module",
      "x-bb-folder" => "WikiPage-Module",
      "x-bb-module-page" => "WikiPage-Module",
      "x-bb-lesson-plan" => "WikiPage-Module",
      "x-bb-syllabus" => "WikiPage",

      # lesson named modules
      "x-bb-flickr-mashup" => "WikiPage",
    }.freeze

    attr_accessor(:title, :body, :id, :files)

    def self.from(xml, pre_data)
      title = xml.xpath("/CONTENT/TITLE/@value").first.text
      type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      type.slice! "resource/"
      if content_type = CONTENT_TYPES[type]
        content_type = content_type.split("-Module")[0]
        content_class = Blacklight.const_get content_type
        content = content_class.new
        content.iterate_xml(xml, pre_data)
      end
    end

    def iterate_xml(xml, pre_data)
      @points = pre_data[:points] || 0
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @id = xml.xpath("/CONTENT/@id").first.text
      @type = xml.xpath("/CONTENT/RENDERTYPE/@value").first.text
      @parent_id = xml.xpath("/CONTENT/PARENTID/@value").first.text
      bb_type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      bb_type.slice! "resource/"
      @module_type = CONTENT_TYPES[bb_type]

      if pre_data[:assignment_id] && pre_data[:assignment_id].length > 0
        @id = pre_data[:assignment_id]
      end

      if @module_type
        item = set_module(xml)
        @module_item = item.canvas_conversion
      end

      @files = xml.xpath("//FILES/FILE").map do |file|
        ContentFile.new(file)
      end
      self
    end

    def get_pre_data(xml, file_name)
      id = xml.xpath("/CONTENT/@id").first.text
      parent_id = xml.xpath("/CONTENT/PARENTID/@value").first.text
      { id: id, parent_id: parent_id, file_name: file_name }
    end

    def set_module(xml)
      if @module_type.include?("-Module")
        @module_type.slice! "-Module"
        @parent_id = @id
      elsif @module_type == "Quiz"
        @module_type = "Quizzes::Quiz"
      end
      ModuleItem.new(@title, @module_type, @id)
    end

    def canvas_conversion(course)
      # need access to the gradebook here -- and file name
      course
    end

    def create_module(course)
      course.canvas_modules = [] if course.canvas_modules.nil?
      cc_module = course.canvas_modules.detect { |a| a.identifier == @parent_id }

      top_module = course.canvas_modules.detect { |c| c.title == "Content" }
      if top_module && !cc_module
        cc_module = top_module if @title == "--TOP--"
        unless @parent_id == top_module.identifier || @parent_id == @id
          course.canvas_modules.each do |course_module|
            c_module = course_module.module_items.detect { |a| a.identifierref == @parent_id }
            if c_module && course_module.identifier != top_module.identifier
              cc_module = course_module
            end
          end
        end
      end

      if cc_module
        @cc_module_id = cc_module.identifier
        cc_module.module_items << @module_item
        course.canvas_modules.delete_if { |a| a.identifier == @parent_id }
      else
        @cc_module_id = @parent_id == "{unset id}" ? @id : @parent_id
        @title = @title == "--TOP--" ? "Content" : @title
        cc_module = Module.new(@title, @cc_module_id)
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
      end
      course.canvas_modules << cc_module
      course
    end
  end
end
