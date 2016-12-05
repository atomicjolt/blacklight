module Blacklight
  class EitherOr < Question
    EITHER_OR = {
      "yes_no.true" => "Yes",
      "yes_no.false" => "No",
      "agree_disagree.true" => "Agree",
      "agree_disagree.false" => "Disagree",
      "right_wrong.true" => "Right",
      "right_wrong.false" => "Wrong",
      "true_false.true" => "Yes",
      "true_false.false" => "Yes",
    }.freeze

    def initialize
      super
      @original_text = ""
    end

    def iterate_xml(data)
      super
      response_block = data.search("flow[@class=RESPONSE_BLOCK]")[0]
      set_answers(data.search("resprocessing"))
      response_block.children.at("flow_label").children.each do |response|
        answer_text = response.children.at("mattext").text
        answer = Answer.new(EITHER_OR[answer_text])
        answer.fraction = get_fraction(answer_text)
        @answers.push(answer)
      end
      self
    end
  end
end
