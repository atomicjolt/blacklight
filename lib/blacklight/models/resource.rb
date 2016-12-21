module Blacklight
  IMPORTED_FILES_DIRNAME = "Imported".freeze

  class Resource
    def fix_images(contents, resources)
      if contents && contents.respond_to?(:empty?) && !contents.empty?
        node_html = Nokogiri::HTML.fragment(contents)

        node_html.search("img").each do |element|
          original_src = element["src"]
          xid = original_src.split("/").last
          file_resource = resources.detect_xid(xid)

          if file_resource
            base = "$IMS-CC-FILEBASE$"
            name = file_resource.name
            element["src"] = "#{base}/#{IMPORTED_FILES_DIRNAME}/#{name}"
          end
        end

        node_html.to_s
      else
        contents
      end
    end

    def matches_xid?(_xid)
      false
    end
  end
end
