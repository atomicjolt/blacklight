module Blacklight
  class ContentFile
    attr_accessor(:id, :name, :linkname)

    def initialize(xml)
      @id = xml.xpath("./@id").first.text
      @name = xml.xpath("./NAME").first.text
      @linkname = xml.xpath("./LINKNAME/@value").first.text
    end

    def canvas_conversion
      query = "?canvas_download=1&amp;canvas_qs_wrap=1"
      href = "$IMS_CC_FILEBASE$/#{@linkname}#{query}"
      %{
        <a
          class="instructure_scribd_file instructure_file_link"
          title="#{@linkname}"
          href="#{href}">
          #{@linkname}
        </a>
      }
    end
  end
end
