module Blacklight
  class Assignment
    def initialize
      @id
      @title = ""
      @body = ""
      @due_at = ""
      @lock_at = ""
      @unlock_at = ""
      @workflow_state = "" # active, unpublished
      @points_possible = ""
      @assignment_group_identifier_ref = ""
      @submission_types = ""
      # online_text_entry, online_upload, on_paper, discussion_topic,
      # online_quiz
      @grading_type = "" # letter_grade, points, percentage, pass_fail
    end

    def iterate_xml(data)
    end

    def canvas_conversion(course)
      course
    end
  end
end
