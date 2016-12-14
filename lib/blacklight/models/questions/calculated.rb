module Blacklight
  class Calculated < Question
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
      @correct_answer_format = 1
      @correct_answer_length = calculated_node.at("answer_scale").text

      @dataset_definitions = parse_vars(calculated_node.at("vars"))
      @var_sets = parse_var_sets(calculated_node.at("var_sets"))

      self
    end

    def parse_vars(parent_node)
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

    def parse_var_sets(parent_node)
      parent_node.search("var_set").map do |var_set|
        vars = {}
        var_set.search("var").each do |var|
          vars[var.attributes["name"].text] = var.text
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
