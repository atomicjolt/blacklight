require "senkyoshi/models/resource"

module Senkyoshi
  ##
  # Class to represent a resource constructed from a single 'dat' file.
  ##
  class FileResource < Resource
    attr_reader(:id)

    def initialize(id = nil)
      @id = id
    end

    def self.from(xml, pre_data, _resource_xids = nil)
      resource = new(pre_data[:file_name])
      resource.iterate_xml(xml, pre_data)
    end

    def iterate_xml(_xml, _pre_data)
      self
    end

    def create_module(course, module_item)
      course.canvas_modules ||= []
      cc_module = course.canvas_modules.
        detect { |a| a.title == MASTER_MODULE }
      if cc_module
        cc_module.module_items << @module_item
      else
        cc_module = Module.new(MASTER_MODULE, MASTER_MODULE)
        cc_module = cc_module.canvas_conversion
        cc_module.module_items << @module_item
        course.canvas_modules << cc_module
      end
      course
    end
  end
end
