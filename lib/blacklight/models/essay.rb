module Blacklight
  class Essay < Question
    def initialize
      super
    end

    def iterate_xml(data)
      super
      itemfeedback = data.at_css("itemfeedback[ident=solution]")
      feedback = itemfeedback.at_css("mat_formattedtext").text
      @general_feedback = feedback
      self
    end

    def canvas_conversion(assessment)
      super
    end

    def process_response(resprocessing)
      super
    end
  end
end
