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
  class JumbledSentence < Question
    def initialize
      @responses = []
      super
    end

    def iterate_xml(data)
      super
      if response_block = data.at("flow[@class=RESPONSE_BLOCK]")
        choices = []
        response_block.at("flow_label").children.each do |response|
          text = response.at("mattext").text
          choices << { id: response.attributes["ident"], text: text }
        end
        set_answers(data.at("resprocessing"))
        correct = data.at("respcondition[title=correct]")
        correct.at("and").children.each do |answer_element|
          id = answer_element.text
          response_label = data.at("response_label[ident='#{id}']")
          answer_text = response_label.at("mattext").text
          answer = Answer.new(answer_text, id)
          resp_ident = answer_element.attributes["respident"].value
          answer.resp_ident = resp_ident
          @responses << { id: resp_ident, choices: choices }
          @answers.push(answer)
        end
      end
      self
    end

    def canvas_conversion(assessment, _resources = nil)
      @question.responses = @responses
      super
    end
  end
end
