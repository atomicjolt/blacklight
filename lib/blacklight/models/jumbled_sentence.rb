module Blacklight
  class JumbledSentence < Question
    def initialize
      super
    end

    def iterate_xml(data)
      super
      if response_block = data.children.search("flow[@class=RESPONSE_BLOCK]")
        set_answers(data.search("resprocessing"))
        correct_element = data.css("respcondition[title=correct]").
          search("varequal")[0]
        response_block.children.at("flow_label").children.each do |response|
          id = response.attributes["ident"].value
          answer_text = response.children.at("mattext").text
          answer = Answer.new(answer_text, id)
          answer.fraction = get_fraction(answer_text)
          if id == correct_element.text
            answer.resp_ident = correct_element.attributes["respident"].value
          end
          @answers.push(answer)
        end
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
