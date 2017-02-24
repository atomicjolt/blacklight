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
  class TrueFalse < Question
    def iterate_xml(data)
      super
      answers_array = [true, false]
      set_answers(data.at("resprocessing"))
      answers_array.each do |answer_text|
        answer = Answer.new(answer_text)
        answer.fraction = get_fraction(answer_text.to_s)
        @answers.push(answer)
      end
      self
    end
  end
end
