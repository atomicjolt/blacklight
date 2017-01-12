require "senkyoshi/models/resource"

module Senkyoshi
  class ContentFile < Resource
    attr_reader(:id, :name, :linkname)

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
      if xid.start_with? "/"
        xid[1..-1]
      else
        xid
      end
    end

    def self.correct_linkname(canvas_file)
      canvas_file.file_path.split("/").last
    end

    def canvas_conversion(resources, canvas_file = nil)
      path = if canvas_file
               canvas_file.file_path
             else
               resource = resources.detect_xid(@name)
               resource.path if resource
             end
      query = "?canvas_download=1&amp;canvas_qs_wrap=1"
      href = "#{BASE}/#{path}#{query}"
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
