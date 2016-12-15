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
        range = CanvasCc::CanvasCC::Models::Range.new
        range.low_range = conditionvar.at("vargte").text.to_i
        range.high_range = conditionvar.at("varlte").text.to_i
        answer_text = conditionvar.at("varequal").text.to_i
        answer = Answer.new(answer_text)
        @ranges[answer.id] = range
        answer.fraction = @max_score
        @answers.push(answer)
      end
      self
    end

    def canvas_conversion(assessment, _resources)
      @question.tolerances = @tolerances
      @question.ranges = @ranges
      super
    end
  end
end
