require "senkyoshi/models/content"

module Senkyoshi
  class Assignment < Content
    def canvas_conversion(course, resources)
      unless @title == "--TOP--"
        assignment = CanvasCc::CanvasCC::Models::Assignment.new
        assignment.identifier = @id
        assignment.title = @title
        assignment.body = fix_html(@body, resources)
        assignment.points_possible = @points
        assignment.assignment_group_identifier_ref = @group_id
        assignment.position = 1
        assignment.workflow_state = "published"
        assignment.submission_types << "online_text_entry"
        assignment.submission_types << "online_upload"
        assignment.grading_type = "points"

        @files.each do |file|
          assignment.body << file.canvas_conversion(resources)
        end
        course = create_module(course)
        course.assignments << assignment
      end
      course
    end
  end
end
