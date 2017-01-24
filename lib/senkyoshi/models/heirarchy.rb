require "senkyoshi/models/resource"

module Senkyoshi
  class Heirarchy
    def self.item_iterator(item, course_toc, discussion_boards)
      if item.search("item").count.zero?
        toc_item = setup_item(item, item.parent, course_toc)
        toc_item[:indent] = 0
        set_discussion_boards(discussion_boards, toc_item)
      else
        item.search("item").flat_map do |internal_item|
          toc_item = setup_item(internal_item, item, course_toc)
          toc_item[:indent] = get_indent(internal_item)
          toc_item = set_discussion_boards(discussion_boards, toc_item)
          toc_item
        end
      end
    end

    def self.get_indent(item, indent = -2)
      return indent if item.parent.name == "organization"
      indent += 1
      get_indent(item.parent, indent)
    end

    def self.set_discussion_boards(discussion_boards, toc_item)
      if toc_item[:internal_handle] == "discussion_board_entry"
        resource = discussion_boards.select do |db|
          title_attribute = db.attributes["title"] || db.attributes["bb:title"]
          title_attribute.value == toc_item[:title]
        end
        if resource.count == 1
          file_attribute = resource.first.attributes["file"] ||
            resource.first.attributes["bb:file"]
          toc_item[:file_name] = file_attribute.value.gsub(".dat", "")
        end
      end
      toc_item
    end

    def self.setup_item(item, parent_item, course_toc)
      if item.attributes["identifierref"]
        title = item.at("title").text
        if title == "--TOP--"
          file_name = item.parent.attributes["identifierref"].value
          title = item.parent.at("title").text
          item_id = item.parent.attributes["identifierref"].
            value.gsub("res", "")
        else
          file_name = item.attributes["identifierref"].value
          if parent_item.attributes["identifierref"]
            item_id = parent_item.attributes["identifierref"].
              value.gsub("res", "")
          else
            item_id = item.attributes["identifierref"].value.gsub("res", "")
          end
        end
        toc_item = course_toc.
          detect { |ct| ct[:original_file] == file_name } || {}
        toc_item[:file_name] = file_name
        toc_item[:title] = title
        toc_item[:parent_id] = get_parent_id(course_toc, item_id)
        toc_item
      end
    end

    def self.get_parent_id(course_toc, item_id)
      header_ids = get_headers(course_toc, "SUBHEADER")
      if header_ids.empty?
        header_ids = get_headers(course_toc, "CONTENT")
      end
      header_id = header_ids.
        reject { |x| x.to_i > item_id.to_i }.
        min_by { |x| (x.to_i - item_id.to_i).abs }

      header_id ? "res" + header_id : nil
    end

    def self.get_headers(course_toc, target_type)
      course_toc.select { |ct| ct[:target_type] == target_type }.
        map { |sh| sh[:original_file].gsub("res", "") }
    end
  end
end
