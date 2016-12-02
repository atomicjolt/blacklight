module Blacklight
  class JumbledSentence < Question
    def initialize
      @responses = []
      super
    end

    def iterate_xml(data)
      super
      if response_block = data.children.search("flow[@class=RESPONSE_BLOCK]")
        choices = []
        response_block.children.at("flow_label").children.each do |response|
          text = response.children.at("mattext").text
          choices << { id: response.attributes["ident"], text: text }
        end
        set_answers(data.search("resprocessing"))
        correct = data.css("respcondition[title=correct]")[0]
        correct.children.at("and").children.each do |answer_element|
          id = answer_element.text
          response_label = data.search("response_label[ident='#{id}']")[0]
          answer_text = response_label.search("mattext").text
          answer = Answer.new(answer_text, id)
          resp_ident = answer_element.attributes["respident"].value
          answer.resp_ident = resp_ident
          @responses << { id: resp_ident, choices: choices }
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
      @question.responses = @responses
      assessment
    end

    def process_response(resprocessing)
      super
    end

    def set_answers(resprocessing)
      super
    end
  end
end
