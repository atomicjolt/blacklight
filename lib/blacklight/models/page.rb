module Blacklight
  class Page < Content
    def canvas_conversion(course)
      page = CanvasCc::CanvasCC::Models::Page.new
      page.body = @body
      page.identifier = @id
      page.page_name = @title

      # Add page links to page body
      @files.each { |f| page.body << f.canvas_conversion }

      course.pages << page
      course
    end
  end
end
