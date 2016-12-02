module Blacklight
  class TrueFalse < Question
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
  end
end
