# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
