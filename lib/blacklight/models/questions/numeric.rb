module Blacklight
  class NumericalQuestion < Question
    def initialize
      @ranges = {}
      @tolerances = {}
      super
    end

    def iterate_xml(data)
      super
      conditionvar = data.at("resprocessing").at("conditionvar")
      if conditionvar
        max_difference = data.at("decvar").attributes["maxnumber"].to_i
        range = CanvasCc::CanvasCC::Models::Range.new
        range.low_range = conditionvar.at("vargte").
          text.to_i - max_difference
        range.high_range = conditionvar.at("varlte").
          text.to_i + max_difference
        answer_text = conditionvar.at("varequal").text
        answer = Answer.new(answer_text)
        @ranges[answer.id] = range
        answer.fraction = @max_score
        @answers.push(answer)
      end
      self
    end

    def canvas_conversion(assessment)
      super
      @question.tolerances = @tolerances
      @question.ranges = @ranges
      assessment
    end
  end
end
