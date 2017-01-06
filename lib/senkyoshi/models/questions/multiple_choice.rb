require "senkyoshi/models/question"

module Senkyoshi
  class MultipleChoice < Question
    def iterate_xml(data)
      super
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        set_answers(data)
        response_block.at("render_choice").children.each do |choice|
          id = choice.at("response_label").attributes["ident"].value
          answer_text = choice.at("mat_formattedtext").text
          answer = Answer.new(answer_text, id)
          answer.fraction = get_fraction(id)
          @answers.push(answer)
        end
      end
      self
    end

    def get_fraction(answer_text)
      if @correct_answers && answer_text == @correct_answers["name"]
        if @correct_answers["fraction"].to_f == 0.0
          1.0
        else
          @correct_answers["fraction"].to_f
        end
      else
        @incorrect_answers["fraction"].to_f
      end
    end
  end
end
