module Blacklight
  class AssignmentGroup
    def initialize(title, group_id)
      @title = title
      @group_weight = ""
      @rules = {}
      @group_id = group_id
    end

    def canvas_conversion(course)
      assignment_group = CanvasCc::CanvasCC::Models::AssignmentGroup.new
      assignment_group.identifier = @group_id
      assignment_group.title = @title
      assignment_group.group_weight = @group_weight
      assignment_group.rules = @rules
      course.assignment_groups << assignment_group
      course
    end
  end
end
