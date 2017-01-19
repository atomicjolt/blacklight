require "senkyoshi/models/resource"
require "senkyoshi/models/content_file"

module Senkyoshi
  class CourseToc
    def self.get_pre_data(xml, file_name)
      target_type = xml.xpath("/COURSETOC/TARGETTYPE/@value").first.text
      if target_type != "MODULE" || target_type != "DIVIDER"
        id = xml.xpath("/COURSETOC/@id").first.text
        title = xml.xpath("/COURSETOC/LABEL/@value").first.text
        internal_handle = xml.xpath("/COURSETOC/INTERNALHANDLE/@value").first.text
        {
          id: id,
          title: title,
          target_type: target_type,
          original_file: file_name,
          internal_handle: internal_handle,
        }
      end
    end
  end
end
