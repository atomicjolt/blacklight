module Blacklight
  class Matching < Question
    def initialize
      super
      @matches = []
      @matching_answers = {}
    end

    def iterate_xml(data)
      super
      resprocessing = data.at("resprocessing")
      @matching_answers = set_matching_answers(resprocessing)
      matches_array = []
      if match_block = data.at("flow[@class=RIGHT_MATCH_BLOCK]")
        match_block.children.each do |match|
          match_text = match.at("mat_formattedtext").text
          matches_array.push(convert_html(match_text))
        end
      end
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        response_block.children.each do |response|
          id = response.at("response_lid").attributes["ident"].value
          response_text = response.at("mat_formattedtext").text
          question = convert_html(response_text)
          answer_id = @matching_answers[id]
          answer = ""
          flow_label = response.at("flow_label")
          flow_label.children.each_with_index do |label, index|
            if label.attributes["ident"].value == answer_id
              answer = matches_array[index]
            end
          end
          @matches << { id: id, question_text: question, answer_text: answer }
        end
      end
      self
    end

    def canvas_conversion(assessment)
      super
      @question.matches = @matches
      assessment
    end

    def set_matching_answers(resprocessing)
      matching_answers = {}
      respcondition = resprocessing.css("respcondition")
      respcondition.each do |condition|
        if condition.attributes["title"] != "incorrect"
          varequal = condition.at("varequal")
          if varequal
            id = varequal.attributes["respident"].value
            matching_answers[id] = varequal.text
          end
        end
      end
      matching_answers
    end
  end
end
