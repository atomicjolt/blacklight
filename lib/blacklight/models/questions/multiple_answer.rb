module Blacklight
  class MultipleAnswer < Question
    def iterate_xml(data)
      super
      if response_block = data.at_css("flow[@class=RESPONSE_BLOCK]")
        set_answers(data.at_css("resprocessing"))
        response_block.children.at("render_choice").children.each do |choice|
          id = choice.children.at("response_label").attributes["ident"].value
          @answer_text = choice.children.at("mat_formattedtext").text
          answer = Answer.new(@answer_text, id)
          answer.fraction = get_fraction(id)
          @answers.push(answer)
        end
      end
      self
    end

    def set_answers(resprocessing)
      @correct_answers = set_correct_answer(resprocessing)
      @incorrect_answers = set_incorrect_answer(resprocessing)
    end

    def set_correct_answer(resprocessing)
      correct_answers = {}
      correct = resprocessing.at_css("respcondition[title=correct]")
      if correct
        correct.at_css("and").children.each do |answer|
          if answer.name == "varequal"
            id = answer.text
            correct_answers[id] = {}
            correct_answers[id]["name"] = id
            if correct.at_css("setvar")
              score = correct.at_css("setvar").text
              score_number = score == "SCORE.max" ? @max_score.to_f : score.to_f
              correct_answers[id]["fraction"] = score_number
            else
              correct_answers[id]["fraction"] = 0
            end
          end
        end
      end
      correct_answers
    end

    def set_incorrect_answer(resprocessing)
      incorrect = resprocessing.at_css("respcondition[ident=incorrect]")
      incorrect_answers = {}
      if incorrect && incorrect.at_css("setvar")
        incorrect_answers["fraction"] = incorrect.at_css("setvar").text
      else
        incorrect_answers["fraction"] = 0
      end
      incorrect_answers
    end
  end
end
