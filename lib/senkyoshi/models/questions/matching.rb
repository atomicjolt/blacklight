require "senkyoshi/models/question"

module Senkyoshi
  class Matching < Question
    def initialize
      super
      @matches = []
      @matching_answers = {}
      @distractors = []
    end

    def iterate_xml(data)
      super
      resprocessing = data.at("resprocessing")
      @matching_answers = set_matching_answers(resprocessing)
      matches_array = []
      answers = []
      if match_block = data.at("flow[@class=RIGHT_MATCH_BLOCK]")
        matches_array = match_block.
          search("flow[@class=FORMATTED_TEXT_BLOCK]").map do |match|
          Nokogiri::HTML(match.text).text
        end
      end
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        response_block.children.each do |response|
          id = response.at("response_lid").attributes["ident"].value
          question = response.at("mat_formattedtext").text
          answer_id = @matching_answers[id]
          answer = ""
          flow_label = response.at("flow_label")
          flow_label.children.each_with_index do |label, index|
            if label.attributes["ident"].value == answer_id
              answer = Nokogiri::HTML(matches_array[index]).text
            end
          end
          answers << answer
          @matches << { id: id, question_text: question, answer_text: answer }
        end
      end
      @distractors = matches_array.reject { |i| answers.include?(i) }
      self
    end

    def canvas_conversion(assessment, _resources = nil)
      @question.matches = @matches
      @question.distractors = @distractors
      super
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
