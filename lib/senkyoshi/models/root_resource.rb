require "senkyoshi/models/resource"

module Senkyoshi
  ##
  # Class to represent a resource constructed from a single 'dat' file.
  ##
  class RootResource < Resource
    attr_reader(:id)

    def initialize(id = nil)
      @id = id
    end

    def self.from(xml = nil, pre_data = nil, _resource_xids = nil)
      resource = new(pre_data[:file_name])
      resource.iterate_xml(xml, pre_data)
    end

    def iterate_xml(_xml, _pre_data)
      self
    end
  end
end
