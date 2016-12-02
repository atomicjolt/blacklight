module Blacklight
  class Numeric < Question
    def initialize
      super
      @ranges = {}
      @tolerances = {}
    end

    def iterate_xml(data)
      super
      conditionvar = data.search("resprocessing")[0].search("conditionvar")[0]
      if conditionvar
        max_difference = data.search("decvar")[0].attributes["maxnumber"].to_i
        range = CanvasCc::CanvasCC::Models::Range.new
        range.low_range = conditionvar.search("vargte").
          text.to_i - max_difference
        range.high_range = conditionvar.search("varlte").
          text.to_i + max_difference
        @answer_text = conditionvar.search("varequal").text
        answer = Answer.new(@answer_text)
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

    def process_response(resprocessing)
      super
    end
  end
end
