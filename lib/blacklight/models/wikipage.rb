module Blacklight
  class WikiPage < Content
    def canvas_conversion(course)
      if @title == "--TOP--"
        if @parent_id == "{unset id}"
          course = create_module(course)
        end
      else
        page = CanvasCc::CanvasCC::Models::Page.new
        page.body = @body
        page.identifier = @id
        page.page_name = @title
        page.workflow_state = "active"

        # Add page links to page body
        @files.each { |f| page.body << f.canvas_conversion }
        course.pages << page

        course = create_module(course)
      end

      course
    end
  end
end
