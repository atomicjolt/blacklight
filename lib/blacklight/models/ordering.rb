module Blacklight
  class Ordering < Question
    def initialize
      super
      @matches = []
      @order_answers = {}
    end

    def iterate_xml(data)
      if response_block = data.children.search("flow[@class=RESPONSE_BLOCK]")
        response_block.children.at("render_choice").children.each do |choice|
          id = choice.children.at("response_label").attributes["ident"].value
          question = @order_answers[id].to_s
          answer = choice.children.at("mat_formattedtext").text
          @matches << { id: id, question_text: question, answer_text: answer }
        end
      end
      super
    end

    def canvas_conversion(assessment)
      super
      if @question_type == "matching_question"
        @question.matches = @matches
      end
      assessment
    end

    def process_response(resprocessing)
      super
      correct = resprocessing.css("respcondition[title=correct]")
      correct.search("and")[0].children.each_with_index do |varequal, index|
        id = varequal.text
        @order_answers[id] = index + 1
      end
    end
  end
end
