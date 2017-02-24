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
  class ModuleConverter
    def self.set_modules(course, pre_data)
      master_module = Course.master_module(course)
      subheaders = get_subheaders(pre_data)
      pre_data.each do |data|
        if check_module_header(data, subheaders)
          course = add_canvas_module(course, data)
        elsif data[:target_type] == "CONTENT"
          module_item = create_module_subheader(data)
          course = add_canvas_module_item(course, module_item, data)
        elsif data[:target_type] == nil || data[:target_type] == "APPLICATION"
          module_item = master_module.module_items.
            detect { |i| i.identifier == data[:file_name] }
          if module_item
            course = add_canvas_module_item(course, module_item, data)
          end
        end
      end
      course.canvas_modules.delete(master_module)
      course
    end

    def self.check_module_header(data, subheaders)
      data[:target_type] == "SUBHEADER" || data[:target_type] == "CONTENT" &&
        (subheaders.empty? || !data[:parent_id])
    end

    def self.get_subheaders(pre_data)
      pre_data.select { |ct| ct[:target_type] == "SUBHEADER" }.
        map { |sh| sh[:original_file].gsub("res", "") }
    end

    def self.create_module_subheader(data)
      ModuleItem.new(
        data[:title],
        "ContextModuleSubHeader",
        data[:file_name],
        nil,
        data[:indent],
        data[:file_name],
      ).canvas_conversion
    end

    def self.add_canvas_module(course, data)
      canvas_module = Module.new(data[:title], data[:file_name])
      course.canvas_modules << canvas_module.canvas_conversion
      course
    end

    def self.add_canvas_module_item(course, module_item, data)
      parent_module = get_subheader_parent(course, data)
      if !parent_module
        parent_module = Module.new(course.title, MAIN_CANVAS_MODULE).
          canvas_conversion
        course.canvas_modules << parent_module
      end
      parent_module.module_items ||= {}
      parent_module.module_items << module_item
      course
    end

    def self.get_subheader_parent(course, data)
      if !data[:parent_id]
        parent_module = course.canvas_modules.
          detect { |a| a.identifier == MAIN_CANVAS_MODULE }
      else
        parent_module = course.canvas_modules.
          detect { |a| a.identifier == data[:parent_id] }
        if !parent_module
          course.canvas_modules.
            reject { |a| a.title == MASTER_MODULE }.
            each do |cc_module|
            if cc_module.module_items
              items = cc_module.module_items.flatten
              item = items.
                detect { |i| i.identifier == data[:parent_id] }
              parent_module = cc_module if item
            end
          end
        end
      end
      parent_module
    end
  end
end
