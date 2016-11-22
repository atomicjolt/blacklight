module Blacklight
  class Content
    attr_accessor(:title, :body, :id, :files)

    def iterate_xml(xml)
      @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      @id = xml.xpath("/CONTENT/@id").first.text
      @files = []
    end

    def canvas_conversion
    end
  end
end
