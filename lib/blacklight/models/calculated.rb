module Blacklight
  class Calculated < Question
    def initialize
      super
    end

    def iterate_xml(data)
      super
      @answer_text = Nokogiri::HTML(data.children.at("formula").text).text
      answer = Answer.new(@answer_text)
      answer.fraction = 1
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
