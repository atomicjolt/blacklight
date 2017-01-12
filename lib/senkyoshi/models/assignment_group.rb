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

    def self.find_group(course, category)
      course.assignment_groups.
        detect { |a| a.title == category }
    end

    def self.find_or_create(course, category)
      assignment_group = find_group(course, category)
      unless assignment_group
        assignment_group = AssignmentGroup.create_assignment_group(category)
        course.assignment_groups << assignment_group
      end
      assignment_group
    end
  end
end
