module Blacklight
  class WikiPage < Content
    def canvas_conversion(course)
      unless @title == "--TOP--"
        page = course.pages.
          select { |p| p.title.start_with? @title }.count
        @title = "#{@title}-#{page + 1}" if page > 0
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