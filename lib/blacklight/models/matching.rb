module Blacklight
  class Matching < Question
    def initialize
      super
      @matches = []
      @matching_answers = {}
    end

    def iterate_xml(data)
      super
      matches_array = []
      if match_block = data.search("flow[@class=RIGHT_MATCH_BLOCK]")[0]
        match_block.children.each do |match|
          match_text = match.children.at("mat_formattedtext").text
          matches_array.push(stripe_html(match_text))
        end
      end
      if response_block = data.search("flow[@class=RESPONSE_BLOCK]")[0]
        response_block.children.each do |response|
          id = response.children.at("response_lid").attributes["ident"].value
          response_text = response.children.at("mat_formattedtext").text
          question = stripe_html(response_text)
          answer_id = @matching_answers[id]
          answer = ""
          flow_label = response.children.at("flow_label")
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

    def process_response(resprocessing)
      super
      respcondition = resprocessing.css("respcondition")
      respcondition.each do |condition|
        if condition.attributes["title"] != "incorrect"
          varequal = condition.children.at("varequal")
          if varequal
            id = varequal.attributes["respident"].value
            @matching_answers[id] = varequal.text
          end
        end
      end
    end
  end
end
