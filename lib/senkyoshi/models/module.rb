require "senkyoshi/models/resource"

module Senkyoshi
  class Module < Resource
    attr_accessor :module_items

    def initialize(title, identifier)
      @identifier = identifier
      @title = title
      @module_items = []
    end

    def canvas_conversion(*)
      CanvasCc::CanvasCC::Models::CanvasModule.new.tap do |cc_module|
        cc_module.identifier = @identifier
        cc_module.title = @title
        cc_module.workflow_state = "published"
        cc_module.module_items = @module_items
      end
    end

    def self.set_modules(course, pre_data)
      master_module = course.canvas_modules.
        detect { |a| a.title == "master_module" }
      subheaders = pre_data.select { |ct| ct[:target_type] == "SUBHEADER" }.
        map { |sh| sh[:original_file].gsub("res", "") }
      pre_data.each do |data|
        if data[:target_type] == "SUBHEADER"
          canvas_module = Module.new(data[:title], data[:file_name])
          course.canvas_modules << canvas_module.canvas_conversion
        elsif data[:target_type] == "CONTENT"
          if subheaders.empty?
            canvas_module = Module.new(data[:title], data[:file_name])
            course.canvas_modules << canvas_module.canvas_conversion
          else
            module_item = ModuleItem.new(
              data[:title],
              "ContextModuleSubHeader",
              data[:file_name],
              nil,
              data[:indent],
              data[:file_name],
            ).canvas_conversion
            if data[:parent_id]
              parent_module = course.canvas_modules.
                detect { |a| a.identifier == data[:parent_id] }
              parent_module.module_items << module_item
            else
              canvas_module = Module.new(data[:title], data[:file_name])
              course.canvas_modules << canvas_module.canvas_conversion
            end
          end
        elsif data[:target_type] == nil || data[:target_type] == "APPLICATION"
          parent_module = get_canvas_module(course.canvas_modules, data)
          if parent_module
            item = master_module.module_items.
              detect { |i| i.identifier == data[:file_name] }
            parent_module.module_items << item if item
          end
        end
      end
      course.canvas_modules.delete(master_module)
      course
    end

    def self.get_canvas_module(modules, data)
      parent_module = modules.
        detect { |cc_module| cc_module.identifier == data[:parent_id] }
      if !parent_module
        modules.reject { |a| a.title == "master_module" }.each do |cc_module|
          if cc_module.module_items
            items = cc_module.module_items.flatten
            item = items.
              detect { |i| i.identifier == data[:parent_id] }
            parent_module = cc_module if item
          end
        end
      end
      parent_module
    end
  end
end
