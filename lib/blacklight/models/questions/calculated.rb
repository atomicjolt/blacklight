module Blacklight
  class Calculated < Question
    def iterate_xml(data)
      super
      answer_text = CGI.unescapeHTML(data.at("formula").text)
      answer = Answer.new(answer_text)
      answer.fraction = 1
      @answers.push(answer)
      self
    end
  end
end
