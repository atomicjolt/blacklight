module Blacklight
  class FillInBlank < Question
    def iterate_xml(data)
      super
      conditionvar = data.at("resprocessing").at("conditionvar")
      answer = Answer.new(conditionvar.at("varequal").text)
      answer.fraction = @max_score
      @answers.push(answer)
      self
    end
  end
end
