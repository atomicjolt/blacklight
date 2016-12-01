module Blacklight
  class FillInBlank < Question
    def initialize
      super
    end

    def iterate_xml(data)
      super
      conditionvar = data.search("resprocessing")[0].search("conditionvar")[0]
      answer = Answer.new(conditionvar.children.at("varequal").text)
      answer.fraction = @max_score
      @answers.push(answer)
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
