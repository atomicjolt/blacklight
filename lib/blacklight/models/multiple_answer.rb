module Blacklight
  class MultipleAnswer < Question
    def iterate_xml(data)
      super
      if response_block = data.children.search("flow[@class=RESPONSE_BLOCK]")
        set_answers(data.search("resprocessing"))
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
      set_correct_answer(resprocessing)
      set_incorrect_answer(resprocessing)
    end

    def set_correct_answer(resprocessing)
      correct = resprocessing.css("respcondition[title=correct]")
      if correct
        correct.search("and").each do |answer|
          if answer.name == "varequal"
            id = answer.text
            @correct_answers[id] = {}
            @correct_answers[id]["name"] = id
            if correct.search("setvar")
              @correct_answers[id]["fraction"] = correct.search("setvar").text
            else
              @correct_answers[id]["fraction"] = 0
            end
          end
        end
      end
    end

    def set_incorrect_answer(resprocessing)
      incorrect = resprocessing.css("respcondition[ident=incorrect]")
      if incorrect && incorrect.search("setvar")
        @incorrect_answers["fraction"] = incorrect.search("setvar").text
      else
        @incorrect_answers["fraction"] = 0
      end
    end
  end
end
