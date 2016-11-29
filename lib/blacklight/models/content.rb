module Blacklight
  class ContentFile
    attr_accessor(:id, :name, :linkname)

    def initialize(xml)
      @id = xml.xpath('./@id').first.text
      @name = xml.xpath('./NAME').first.text
      @linkname = xml.xpath('./LINKNAME/@value').first.text
    end

    def canvas_conversion
      "<a href='$IMS_CC_FILEBASE$/#{@linkname}'>#{@linkname}</a>"
    end
  end

  class Content
    attr_accessor(:title, :body, :id, :files)

    def iterate_xml(xml)
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @id = xml.xpath("/CONTENT/@id").first.text
      @files = []
      xml.xpath("//FILES/FILE").each do |file|
        @files << ContentFile.new(file)
      end
      self
    end

    def canvas_conversion(course)
      page = CanvasCc::CanvasCC::Models::Page.new
      page.body = @body
      page.identifier = @id
      page.page_name = @title

      # Add page links to page body
      @files.each { |f| page.body << f.canvas_conversion }

      course.pages << page
      course
    end
  end
end
