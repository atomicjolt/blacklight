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
  class Calculated < Question
    attr_reader :dataset_definitions, :var_sets

    def initialize
      @dataset_definitions = []
      @var_sets = []
      @correct_answer_length = 0
      @correct_answer_format = 0
      @tolerance = 0
      super
    end

    def canvas_conversion(*)
      @question.dataset_definitions = @dataset_definitions
      @question.var_sets = @var_sets
      @question.correct_answer_length = @correct_answer_length
      @question.correct_answer_format = @correct_answer_format
      @question.tolerance = @tolerance
      super
    end

    def iterate_xml(data)
      super
      calculated_node = data.at("itemproc_extension > calculated")
      math_ml = CGI.unescapeHTML(calculated_node.at("formula").text)
      formula = Nokogiri::HTML(math_ml).text

      answer = Answer.new(formula)
      @answers.push(answer)

      @tolerance = calculated_node.at("answer_tolerance").text
      # canvas_cc only uses the correct_answer_length if the
      # correct_answer_format is 1. It is not known what 1 represents.
      @correct_answer_format = 1
      @correct_answer_length = calculated_node.at("answer_scale").text

      @dataset_definitions = _parse_vars(calculated_node.at("vars"))
      @var_sets = _parse_var_sets(calculated_node.at("var_sets"))

      self
    end

    def _parse_vars(parent_node)
      parent_node.search("var").map do |var|
        scale = var.attributes["scale"]
        min = var.at("min").text
        max = var.at("max").text
        options = ":#{min}:#{max}:#{scale}"

        {
          name: var.attributes["name"].value,
          options: options,
        }
      end
    end

    def _parse_var_sets(parent_node)
      parent_node.search("var_set").map do |var_set|
        vars = var_set.search("var").each_with_object({}) do |var, hash|
          hash[var.attributes["name"].text] = var.text
        end

        {
          ident: var_set.attributes["ident"].text,
          answer: var_set.at("answer").text,
          vars: vars,
        }
      end
    end
  end
end
