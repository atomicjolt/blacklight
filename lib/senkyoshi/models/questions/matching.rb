# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "senkyoshi/models/question"

module Senkyoshi
  class Matching < Question
    TAGS_PATTERN = Regexp.union(
      /<\/?p[^>]*>/i,             # <p> tags
      /<\/?b[^>]*>/i,             # <b> tags
      /<\/?strong[^>]*>/i,        # <strong> tags
      /<\/?em[^>]*>/i,            # <em> tags
      /<\/?span[^>]*>/i,          # <span> tags
      /<\/?font[^>]*>/i,          # <font> tags
      /<\/?i(?!mg)[^>]*>/i,       # <i> tags, no <img>
      / style=("|')[^"']*("|')/i, # inline styles
    )

    def initialize
      super
      @matches = []
      @matching_answers = {}
      @distractors = []
    end

    def strip_select_html(text)
      text.gsub(TAGS_PATTERN, "")
    end

    def iterate_xml(data)
      super
      resprocessing = data.at("resprocessing")
      @matching_answers = set_matching_answers(resprocessing)
      matches_array = []
      answers = []
      if match_block = data.at("flow[@class=RIGHT_MATCH_BLOCK]")
        matches_array = match_block.
          search("flow[@class=FORMATTED_TEXT_BLOCK]").
          map { |match| strip_select_html(match.text) }
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
              answer = matches_array[index]
            end
          end

          answers << answer
          @matches << {
            id: Senkyoshi.create_random_hex,
            question_text: question,
            answer_text: answer,
          }
        end
      end
      @distractors = matches_array.reject { |i| answers.include?(i) }
      self
    end

    def canvas_conversion(assessment, resources)
      @matches.each do |match|
        match[:question_text] = fix_html(match[:question_text], resources)
        match[:answer_text] = fix_html(match[:answer_text], resources)
      end

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
