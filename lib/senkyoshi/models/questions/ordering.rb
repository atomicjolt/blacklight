module Senkyoshi
  class Ordering < Question
    def initialize
      super
      @matches = []
      @order_answers = {}
    end

    def iterate_xml(data)
      super
      resprocessing = data.at("resprocessing")
      @order_answers = set_order_answers(resprocessing)
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        response_block.at("render_choice").children.each do |choice|
          id = choice.at("response_label").attributes["ident"].value
          question = @order_answers[id].to_s
          answer = choice.at("mat_formattedtext").text
          @matches << { id: id, question_text: question, answer_text: answer }
        end
        @matches = @matches.sort_by { |hsh| hsh[:question_text] }
      end
      self
    end

    def canvas_conversion(assessment, _resources = nil)
      @question.matches = @matches
      super
    end

    def set_order_answers(resprocessing)
      order_answers = {}
      correct = resprocessing.at("respcondition[title=correct]")
      correct.at("and").children.each_with_index do |varequal, index|
        id = varequal.text
        order_answers[id] = index + 1
      end
      order_answers
    end
  end
end
