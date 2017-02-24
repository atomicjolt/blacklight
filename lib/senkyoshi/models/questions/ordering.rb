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
  class Ordering < Question
    def initialize
      super
      @matches = []
      @order_answers = {}
    end

    def iterate_xml(data)
      super
      resprocessing = data.at("resprocessing")
      @order_answers = set_order_answers(resprocessing)
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        response_block.at("render_choice").children.each do |choice|
          id = choice.at("response_label").attributes["ident"].value
          question = @order_answers[id].to_s
          answer = choice.at("mat_formattedtext").text
          @matches << { id: id, question_text: question, answer_text: answer }
        end
        @matches = @matches.sort_by { |hsh| hsh[:question_text] }
      end
      self
    end

    def canvas_conversion(assessment, _resources = nil)
      @question.matches = @matches
      super
    end

    def set_order_answers(resprocessing)
      order_answers = {}
      correct = resprocessing.at("respcondition[title=correct]")
      if correct
        correct.at("and").children.each_with_index do |varequal, index|
          id = varequal.text
          order_answers[id] = index + 1
        end
      end
      order_answers
    end
  end
end
