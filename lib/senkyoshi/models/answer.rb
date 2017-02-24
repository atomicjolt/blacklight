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

require "senkyoshi/models/resource"

module Senkyoshi
  class Answer < Resource
    attr_reader :id, :answer_text
    attr_accessor :fraction, :resp_ident, :feedback

    def initialize(text, id = Senkyoshi.create_random_hex)
      @answer_text = text
      @resp_ident = ""
      @fraction = ""
      @feedback = ""
      @points = 0
      @id = id
    end

    def iterate_xml
      self
    end

    def canvas_conversion(question, resources)
      answer = CanvasCc::CanvasCC::Models::Answer.new(@answer_text)
      answer.answer_text = fix_html(@answer_text, resources)
      answer.id = @id
      answer.fraction = @fraction
      answer.feedback = @feedback
      answer.resp_ident = @resp_ident
      question.answers << answer
      question
    end
  end
end
