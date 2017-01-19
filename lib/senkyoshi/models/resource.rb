module Senkyoshi
  class Resource
    attr_reader(:id)

    def initialize(id = nil)
      @id = id
    end

    def cleanup; end

    def self.from(xml = nil, pre_data = nil, _resource_xids = nil)
      resource = new(pre_data[:file_name])
      resource.iterate_xml(xml, pre_data)
    end

    def iterate_xml(_xml, _pre_data)
      self
    end

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

    def strip_xid(name)
      name.gsub(/__xid-[0-9]+_[0-9]+/, "")
    end

    def _matches_directory_xid?(xid, directory)
      dir_xid = directory[/xid-[0-9]+_[0-9]+\z/]
      xid == dir_xid
    end

    def _find_directories(resources)
      resources.resources.map do |resource|
        if resource.respond_to?(:location)
          File.dirname(resource.location)[/csfiles.*/]
        end
      end.uniq.compact
    end

    def _fix_path(original_src, resources, dir_names)
      xid = original_src.split("/").last
      file_resource = resources.detect_xid(xid)

      if file_resource
        "#{FILE_BASE}/#{file_resource.path}"
      else
        matching_dir = dir_names.detect do |dir|
          _matches_directory_xid?(xid, dir)
        end

        if matching_dir
          "#{DIR_BASE}/#{strip_xid(matching_dir)}"
        end
      end
    end

    def _search_and_replace(resources, node_html, tag, attr)
      dir_names = _find_directories(resources)

      node_html.search(tag).each do |element|
        original_src = element[attr]

        if original_src
          path = _fix_path(original_src, resources, dir_names)
          element[attr] = path if path
        end
      end
    end

    def self.get_pre_data(_xml, _file_name); end
  end
end
