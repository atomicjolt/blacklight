module Blacklight
  class JumbledSentence < Question
    def initialize
      @responses = []
      super
    end

    def iterate_xml(data)
      super
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        choices = []
        response_block.at("flow_label").children.each do |response|
          text = response.at("mattext").text
          choices << { id: response.attributes["ident"], text: text }
        end
        set_answers(data.at("resprocessing"))
        correct = data.at("respcondition[title=correct]")
        correct.at("and").children.each do |answer_element|
          id = answer_element.text
          response_label = data.at("response_label[ident='#{id}']")
          answer_text = response_label.at("mattext").text
          answer = Answer.new(answer_text, id)
          resp_ident = answer_element.attributes["respident"].value
          answer.resp_ident = resp_ident
          @responses << { id: resp_ident, choices: choices }
          @answers.push(answer)
        end
      end
      self
    end

    def canvas_conversion(assessment)
      super
      @question.responses = @responses
      assessment
    end
  end
end
