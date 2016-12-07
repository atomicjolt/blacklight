module Blacklight
  class Answer
    attr_reader :id
    attr_accessor :fraction, :resp_ident, :feedback

    def initialize(text, id = Blacklight.create_random_hex)
      @answer_text = text
      @resp_ident = ""
      @fraction = ""
      @feedback = ""
      @points = 0
      @id = id
    end

    def iterate_xml
      self
    end

    def canvas_conversion(question)
      answer = CanvasCc::CanvasCC::Models::Answer.new(@answer_text)
      answer.answer_text = @answer_text
      answer.id = @id
      answer.fraction = @fraction
      answer.feedback = @feedback
      answer.resp_ident = @resp_ident
      question.answers << answer
      question
    end
  end
end