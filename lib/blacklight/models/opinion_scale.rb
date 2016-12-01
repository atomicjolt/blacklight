module Blacklight
  class OpinionScale < Question
    def initialize
      super
    end

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
