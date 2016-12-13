module Blacklight
  class Calculated < Question
    def iterate_xml(data)
      super
      calculated_node = data.at("itemproc_extension > calculated")
      formula = CGI.unescapeHTML(calculated_node.at("forumla").text)
      answer = Answer.new(forumla)
      @answers.push(answer)
      answer_tolerance = calculated_node.at("answer_tolerance").text
      decimal_places = 0

      @vars = parse_vars(calculated_node.at("vars"))
      var_sets = parse_var_sets(calculated_node.at("var_sets"))

      answer_text = CGI.unescapeHTML(data.at("formula").text)
      answer = Answer.new(answer_text)
      answer.fraction = 1
      @answers.push(answer)
      self
    end

    def parse_vars(parent_node)
      parent_node.search("var").map do |var|
        scale = var.attributes["scale"]
        min = var.at("min").text
        max = var.at("max").text
        options = ":#{min}:#{max}:#{scale}"

        {
          name: var.attributes["name"],
          options: options,
        }
      end
    end

    def parse_var_sets(parent_node)
      parent_node.search("var_set").map do |var_set|
        var = var_set.at("var")

        {
          ident: var_set.attributes["ident"],
          answer: var_set.at("answer").text,
          var: {
            name: var.attributes["name"],
            text: var.text,
          },
        }
      end
    end
  end
end
