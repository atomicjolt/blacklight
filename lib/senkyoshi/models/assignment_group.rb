require "senkyoshi/models/resource"

module Senkyoshi
  class AssignmentGroup < Resource
    attr_reader :id
    def initialize(name, id)
      @title = name
      @group_weight = ""
      @rules = {}
      @id = id
    end

    def canvas_conversion
      assignment_group = CanvasCc::CanvasCC::Models::AssignmentGroup.new
      assignment_group.identifier = @id
      assignment_group.title = @title
      assignment_group.group_weight = @group_weight
      assignment_group.rules = @rules
      assignment_group
    end

    def self.create_assignment_group(group_name)
      id = Senkyoshi.create_random_hex
      group = AssignmentGroup.new(group_name, id)
      group.canvas_conversion
    end
  end
end
