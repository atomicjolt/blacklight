module Blacklight
  class Assignment < Content
    def canvas_conversion(course)
      super
      assignment = CanvasCc::CanvasCC::Models::Assignment.new
      assignment.identifier = @id
      assignment.title = @title
      assignment.body = @body
      assignment.assignment_group_identifier_ref = @group_id
      assignment.position = 1
      assignment.workflow_state = "published"
      assignment.submission_types << "online_text_entry"
      assignment.submission_types << "online_upload"
      assignment.grading_type = "points"

      # Add page links to page body
      @files.each { |f| assignment.body << f.canvas_conversion }
      course = create_module(course)

      course.assignments << assignment
      course
    end
  end
end
