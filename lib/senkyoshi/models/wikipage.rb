require "senkyoshi/models/content"

module Senkyoshi
  class WikiPage < Content
    include Senkyoshi

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
        if @extendeddata
          @body = %{
            #{@body}
            #{_extendeddata(@extendeddata)}
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

    def _extendeddata(extendeddata)
      Nokogiri::XML(extendeddata).
        search("LessonPlanComponent").
        map do |node|
          visible = true?(node.search("vislableToStudents").attr("value").to_s)
          overridden = true?(node.search("labelOverridden").attr("value").to_s)
          _component_label(node.search("componentLabel"), visible, overridden) +
            node.search("componentValue").attr("value").to_s
        end.
        compact.
        join(" ")
    end

    def _component_label(component_label, visible, overridden)
      if visible
        val = component_label.attr("value").to_s
        if overridden
          val
        else
          val.split(".").last.capitalize
        end
      else
        ""
      end
    end
  end
end
