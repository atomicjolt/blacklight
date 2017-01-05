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
        @body = _set_body(@body, @url, @extendeddata)
        page.body = fix_html(@body, resources)
        page.identifier = @id
        page.page_name = @title
        page.workflow_state = "active"

        # Add page links to page body
        @files.each do |file|
          if canvas_file = course.files.detect { |f| f.identifier == file.name }
            canvas_file_path = canvas_file.file_path.split("/").last
            file.linkname = canvas_file_path
            page.body << file.canvas_conversion
          else
            page.body << "<p>File: " + file.linkname +
              " -- doesn't exist in blackboard</p>"
          end
        end
        course.pages << page

        course = create_module(course)
      end

      course
    end

    def _set_body(original_body, url, extendeddata)
      body = original_body.dup
      if !url.empty?
        body = %{
          <a href="#{url}">
            #{url}
          </a>
          #{body}
        }
      end
      if extendeddata
        body = %{
          #{body}
          #{_extendeddata(extendeddata)}
        }
      end
      body
    end

    def _extendeddata(extendeddata)
      Nokogiri::XML(extendeddata).
        search("LessonPlanComponent").
        map do |node|
          _component_label(node) + node.search("componentValue/@value").to_s
        end.
        compact.
        join(" ")
    end

    def _component_label(node)
      visible = true?(node.search("vislableToStudents/@value").to_s)
      if visible
        component_label = node.search("componentLabel/@value").to_s
        overridden = true?(node.search("labelOverridden/@value").to_s)
        if overridden
          component_label
        else
          component_label.split(".").last.capitalize
        end
      else
        ""
      end
    end
  end
end
