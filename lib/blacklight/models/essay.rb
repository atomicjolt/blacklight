module Blacklight
  class Essay < Question
    def iterate_xml(data)
      super
      itemfeedback = data.at_css("itemfeedback[ident=solution]")
      feedback = itemfeedback.at_css("mat_formattedtext").text
      @general_feedback = feedback
      self
    end
  end
end
