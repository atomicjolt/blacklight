module Blacklight
  class ContentFile
    attr_accessor(:id, :name, :linkname)

    def initialize(xml)
      @id = xml.xpath("./@id").first.text
      @name = xml.xpath("./NAME").first.text
      @linkname = xml.xpath("./LINKNAME/@value").first.text
    end

    def canvas_conversion
      "<a href='$IMS_CC_FILEBASE$/#{@linkname}'>#{@linkname}</a>"
    end
  end
end
