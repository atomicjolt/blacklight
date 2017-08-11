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

require "senkyoshi/models/qti"

module Senkyoshi
  class QuestionBank < QTI
    TAGS = {
      "<p><span size=\"2\" style=\"font-size: small;\">.</span></p>" => "",
      "<p>.</p>" => "",
    }.freeze
    TAGS_RE = Regexp.union(TAGS.keys)

    def canvas_conversion(course, resources)
      question_bank = CanvasCc::CanvasCC::Models::QuestionBank.new
      question_bank.identifier = @id
      question_bank.title = @title
      question_bank = setup_question_bank(question_bank, resources)
      course.question_banks << question_bank
      course
    end

    def setup_question_bank(question_bank, resources)
      question_bank = create_items(question_bank, resources)
      question_bank
    end

    def create_items(question_bank, resources)
      @items = @items - ["", nil]
      questions = @items.map do |item|
        Question.from(item)
      end
      question_bank.questions = []
      questions.each do |item|
        question = item.canvas_conversion(question_bank, resources)
        question.material = clean_up_material(question.material)
        question_bank.questions << question
      end
      question_bank
    end

    # This is to remove the random extra <p>.</p> included in the
    # description that is just randomly there
    def clean_up_material(material)
      if material
        material = material.gsub(TAGS_RE, TAGS)
        material = material.strip
      end
      material
    end
  end
end
