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
