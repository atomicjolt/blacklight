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
  class NumericalQuestion < Question
    def initialize
      @ranges = {}
      @tolerances = {}
      super
    end

    def iterate_xml(data)
      super
      if data.at("resprocessing")
        conditionvar = data.at("resprocessing").at("conditionvar")
      end

      if conditionvar
        range = CanvasCc::CanvasCC::Models::Range.new
        range.low_range = conditionvar.at("vargte").text.to_i
        range.high_range = conditionvar.at("varlte").text.to_i
        answer_text = conditionvar.at("varequal").text.to_i
        answer = Answer.new(answer_text)
        @ranges[answer.id] = range
        answer.fraction = @max_score
        @answers.push(answer)
      end
      self
    end

    def canvas_conversion(assessment, _resources = nil)
      @question.tolerances = @tolerances
      @question.ranges = @ranges
      super
    end
  end
end
