require "blacklight/models/resource"

module Blacklight
  class AssignmentGroup < Resource
    attr_reader :id
    def initialize(name, group_id)
      @title = name
      @group_weight = ""
      @rules = {}
      @id = group_id
    end

    def canvas_conversion(course, _resources = nil)
      assignment_group = CanvasCc::CanvasCC::Models::AssignmentGroup.new
      assignment_group.identifier = @id
      assignment_group.title = @title
      assignment_group.group_weight = @group_weight
      assignment_group.rules = @rules
      course.assignment_groups << assignment_group
      course
    end
  end
end
