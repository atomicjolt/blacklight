require "senkyoshi/models/question"

module Senkyoshi
  class FillInBlank < Question
    def iterate_xml(data)
      super
      if data.at("resprocessing")
        conditionvar = data.at("resprocessing").at("conditionvar")
      end
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
