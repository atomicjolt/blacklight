module Senkyoshi
  class FillInBlank < Question
    def iterate_xml(data)
      super
      conditionvar = data.at("resprocessing").at("conditionvar")
      # not all fill in the blank questions have answers(ie: surveys)
      if conditionvar
        answer = Answer.new(conditionvar.at("varequal").text)
        answer.fraction = @max_score
        @answers.push(answer)
      end
      self
    end
  end
end
