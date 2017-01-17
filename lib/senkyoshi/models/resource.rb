module Senkyoshi
  class Resource
    def cleanup; end

    def fix_html(contents, resources)
      if contents && contents.respond_to?(:empty?) && !contents.empty?
        node_html = Nokogiri::HTML.fragment(contents)

        _search_and_replace(resources, node_html, "a", "href")
        _search_and_replace(resources, node_html, "img", "src")

        node_html.to_s
      else
        contents
      end
    end

    def matches_xid?(_xid)
      false
    end

    def _search_and_replace(resources, node_html, tag, attr)
      node_html.search(tag).each do |element|
        original_src = element[attr]
        if original_src
          xid = original_src.split("/").last
          file_resource = resources.detect_xid(xid)
          if file_resource
            base = File.file?(file_resource.location) ? FILE_BASE : DIR_BASE
            element[attr] = "#{base}/#{file_resource.path}"
          end
        end
      end
    end
  end
end
