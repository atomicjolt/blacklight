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
  class EitherOr < Question
    EITHER_OR = {
      "yes_no.true" => "Yes",
      "yes_no.false" => "No",
      "agree_disagree.true" => "Agree",
      "agree_disagree.false" => "Disagree",
      "right_wrong.true" => "Right",
      "right_wrong.false" => "Wrong",
      "true_false.true" => "True",
      "true_false.false" => "False",
    }.freeze

    def initialize
      super
      @original_text = ""
    end

    def iterate_xml(data)
      super
      set_answers(data.at("resprocessing"))
      data.at("flow_label").children.each do |response|
        answer_text = response.at("mattext").text
        answer = Answer.new(EITHER_OR[answer_text])
        answer.fraction = get_fraction(answer_text)
        @answers.push(answer)
      end
      self
    end
  end
end
