require "senkyoshi/models/question"

module Senkyoshi
  class Essay < Question
    def iterate_xml(data)
      super
      itemfeedback = data.at("itemfeedback[ident=solution]")
      feedback = itemfeedback.at("mat_formattedtext").text
      @general_feedback = feedback
      self
    end
  end
end
