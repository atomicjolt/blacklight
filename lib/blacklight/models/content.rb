module Blacklight

  class ContentFile
    attr_accessor(:id, :name, :linkname)

    def initialize(xml)
      @id = xml.xpath('./@id').first.text
      @name = xml.xpath('./NAME').first.text
      @linkname = xml.xpath('./LINKNAME/@value').first.text
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
    end

    def canvas_conversion
    end
  end
end
