module Blacklight
  class FillInBlank < Question
    def iterate_xml(data)
      super
      conditionvar = data.search("resprocessing")[0].search("conditionvar")[0]
      answer = Answer.new(conditionvar.children.at("varequal").text)
      answer.fraction = @max_score
      @answers.push(answer)
      self
    end
  end
end
