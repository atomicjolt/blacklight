module Blacklight
  class TrueFalse < Question
    def initialize
      super
    end

    def iterate_xml(data)
      super
      answers_array = [true, false]
      set_answers(data.search("resprocessing"))
      answers_array.each do |answer_text|
        answer = Answer.new(answer_text)
        answer.fraction = get_fraction(answer_text)
        @answers.push(answer)
      end
      self
    end

    def get_fraction(answer_text)
      super
    end

    def canvas_conversion(assessment)
      super
    end

    def process_response(resprocessing)
      super
    end

    def set_answers(resprocessing)
      super
    end
  end
end
