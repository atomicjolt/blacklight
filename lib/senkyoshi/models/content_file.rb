require "senkyoshi/models/resource"

module Senkyoshi
  class ContentFile < Resource
    attr_accessor(:id, :name, :linkname)

    def initialize(xml)
      @id = xml.xpath("./@id").first.text
      @linkname = xml.xpath("./LINKNAME/@value").first.text
      @name = ContentFile.clean_xid xml.xpath("./NAME").first.text
    end

    ##
    # Remove leading slash if necessary so that ContentFile.name will match
    # the Senkyoshi.xid
    ##
    def self.clean_xid(xid)
      xid[1..-1] if xid.start_with? "/"
    end

    def self.correct_file_name(canvas_file)
      canvas_file.file_path.split("/").last
    end

    def canvas_conversion(canvas_file)
      @linkname = ContentFile.correct_file_name(canvas_file)
      query = "?canvas_download=1&amp;canvas_qs_wrap=1"
      href = "$IMS_CC_FILEBASE$/#{IMPORTED_FILES_DIRNAME}/#{@linkname}#{query}"
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
