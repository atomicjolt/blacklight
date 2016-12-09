module Blacklight
  class Content
    CONTENT_TYPES = {
      # ignore
      # "x-bb-asmt-test-link",
      # "x-bb-asmt-survey-link",
      # "x-bb-courselink",

      # "x-bb-folder"

      # assignments
      "x-bb-assignment" => "Assignment",
      "x-bbpi-selfpeer-type1" => "Assignment",

      # contents
      "x-bb-document" => "Page",
      "x-bb-file" => "Page",
      "x-bb-audio" => "Page",
      "x-bb-image" => "Page",
      "x-bb-video" => "Page",
      "x-bb-externallink" => "Page",

      # lesson named modules
      "x-bb-lesson" => "Page",

      # lesson named modules
      "x-bb-lesson-plan" => "Page",
      "x-bb-syllabus" => "Page",

      # lesson named modules
      "x-bb-folder" => "Page",

      # lesson named modules
      "x-bb-module-page" => "Page",

      # lesson named modules
      "x-bb-blankpage" => "Page",

      # lesson named modules
      "x-bb-flickr-mashup" => "Page",
    }.freeze

    attr_accessor(:title, :body, :id, :files)

    def self.from(xml)
      full_type = xml.xpath("/CONTENT/CONTENTHANDLER/@value").first.text
      type = full_type.slice! "resource/"
      content_class = Blacklight.const_get CONTENT_TYPES[type]
      content = content_class.new
      content.iterate_xml(item)
    end

    def iterate_xml(xml)
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @id = xml.xpath("/CONTENT/@id").first.text
      @type = xml.xpath("/CONTENT/RENDERTYPE/@value").first.text
      @parent_id = xml.xpath("/CONTENT/PARENTID/@value").first.text
      @files = xml.xpath("//FILES/FILE").map do |file|
        ContentFile.new(file)
      end
      self
    end

    def canvas_conversion(course)
      course
    end
  end
end
