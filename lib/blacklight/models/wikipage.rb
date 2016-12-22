require "blacklight/models/resource"

module Blacklight
  class WikiPage < Content
    def canvas_conversion(course, resources)
      unless @title == "--TOP--"
        page_count = course.pages.
          select { |p| p.title.start_with? @title }.count
        @title = "#{@title}-#{page_count + 1}" if page_count > 0
        page = CanvasCc::CanvasCC::Models::Page.new
        if !@url.empty?
          @body = %{
            <a href="#{@url}">
              #{@url}
            </a>
            #{@body}
          }
        end
        page.body = fix_html(@body, resources)
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
