module Blacklight
  class FillInBlankPlus < Question
    def iterate_xml(data)
      super
      conditionvar = data.at("resprocessing").at("conditionvar")
      conditionvar.at("and").children.each do |or_child|
        or_child.children.each do |varequal|
          answer = Answer.new(varequal.text)
          answer.resp_ident = varequal.attributes["respident"].value
          answer.fraction = @max_score
          @answers.push(answer)
        end
      end
      self
    end
  end
end
