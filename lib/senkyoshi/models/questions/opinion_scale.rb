module Senkyoshi
  class OpinionScale < Question
    def iterate_xml(data)
      super
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        set_answers(data.at("resprocessing"))
        response_block.at("render_choice").children.each do |choice|
          id = choice.at("response_label").attributes["ident"].value
          @answer_text = choice.at("mat_formattedtext").text
          answer = Answer.new(@answer_text, id)
          answer.fraction = get_fraction(id)
          @answers.push(answer)
        end
      end
      self
    end
  end
end
