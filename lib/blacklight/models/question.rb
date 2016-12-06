module Blacklight
  class Question
    QUESTION_TYPE = {
      "True/False" => "true_false_question",
      "Numeric" => "numerical_question",
      "Multiple Choice" => "multiple_choice_question",
      "Multiple Answer" => "multiple_answers_question",
      "Matching" => "matching_question",
      "Fill in the Blank" => "short_answer_question",
      "Fill in the Blank Plus" => "fill_in_multiple_blanks_question",
      "File Upload" => "file_upload_question",
      "Essay" => "essay_question",
      "Calculated" => "short_answer_question",
      "Jumbled Sentence" => "multiple_dropdowns_question",
      "Either/Or" => "multiple_choice_question",
      "Hot Spot" => "text_only_question",
      "Opinion Scale" => "multiple_answers_question",
      "Ordering" => "matching_question",
      "Quiz Bowl" => "text_only_question",
      "Short Response" => "essay_question",
    }.freeze

    ITEM_FUNCTION = {
      "True/False" => "TrueFalse",
      "Numeric" => "Numeric",
      "Multiple Choice" => "MultipleChoice",
      "Multiple Answer" => "MultipleAnswer",
      "Matching" => "Matching",
      "Fill in the Blank" => "FillInBlank",
      "Fill in Multiple Blanks" => "FillInMultipleBlanks",
      "Fill in the Blank Plus" => "FillInBlankPlus",
      "File Upload" => "FileUpload",
      "Essay" => "Essay",
      "Calculated" => "Calculated",
      "Jumbled Sentence" => "JumbledSentence",
      "Either/Or" => "EitherOr",
      "Hot Spot" => "HotSpot",
      "Opinion Scale" => "OpinionScale",
      "Ordering" => "Ordering",
      "Quiz Bowl" => "QuizBowl",
      "Short Response" => "ShortResponse",
    }.freeze

    def self.from(item)
      type = item.search("bbmd_questiontype").children.text
      item_class = Blacklight.const_get ITEM_FUNCTION[type]
      item_class.new
    end

    def initialize
      @original_identifier = ""
      @question = nil
      @question_type = ""
      @points_possible = ""
      @title = "Question"
      @material = ""
      @answers = []
      @general_feedback = ""
      @general_correct_feedback = ""
      @general_incorrect_feedback = ""
      @blackboard_type = ""
      @correct_answers = {}
      @incorrect_answers = {}
      @max_score = 1
    end

    def iterate_xml(data)
      @original_identifier = data.children.at("bbmd_asi_object_id").text
      @blackboard_type = data.children.at("bbmd_questiontype").text
      @question_type = QUESTION_TYPE[@blackboard_type]
      @points_possible = data.children.at("qmd_absolutescore_max").text
      @title = data.attributes["title"].value
      iterate_item(data)
      self
    end

    def canvas_conversion(assessment)
      @question = CanvasCc::CanvasCC::Models::Question.create(@question_type)
      @question.identifier = Blacklight.create_random_hex
      @question.title = convert_html(@title)
      @question.points_possible = @points_possible
      @question.material = convert_html(@material)
      @question.general_feedback = convert_html(@general_feedback)
      @general_correct_feedback = convert_html(@general_correct_feedback)
      @question.general_correct_feedback = @general_correct_feedback
      @general_incorrect_feedback = convert_html(@general_incorrect_feedback)
      @question.general_incorrect_feedback = @general_incorrect_feedback
      @question.answers = []
      @answers.each do |answer|
        @question = answer.canvas_conversion(@question)
      end
      assessment.items << @question
      assessment
    end

    def convert_html(contents)
      if contents && !contents.empty?
        Nokogiri::HTML(contents).text
      else
        contents
      end
    end

    def get_fraction(answer_text)
      if @correct_answers && answer_text == @correct_answers["name"]
        @correct_answers["fraction"].to_f
      else
        @incorrect_answers["fraction"].to_f
      end
    end

    def set_answers(resprocessing)
      set_correct_answers(resprocessing)
      set_incorrect_answers(resprocessing)
    end

    def set_correct_answers(resprocessing)
      correct = resprocessing.search("respcondition[title=correct]")
      if correct
        if correct.search("varequal")
          @correct_answers["name"] = correct.search("varequal").text
        end
        score = correct.search("setvar") ? correct.search("setvar").text : 0
        score_number = score == "SCORE.max" ? @max_score.to_f : score.to_f
        if score_number.positive?
          @correct_answers["fraction"] = score_number.to_f / @max_score.to_f
        else
          @correct_answers["fraction"] = 0
        end
      end
    end

    def set_incorrect_answers(resprocessing)
      incorrect = resprocessing.css("respcondition[title=incorrect]")
      if incorrect
        if incorrect.search("varequal")
          @incorrect_answers["name"] = incorrect.search("varequal").text
        end
        score = incorrect.search("setvar") ? incorrect.search("setvar").text : 0
        score_number = score == "SCORE.max" ? @max_score.to_f : score.to_f
        if score_number.positive?
          @incorrect_answers["fraction"] = score_number.to_f / @max_score.to_f
        else
          @incorrect_answers["fraction"] = 0
        end
      end
    end

    def iterate_item(data)
      @general_correct_feedback = set_correct_feedback(data)
      @general_incorrect_feedback = set_incorrect_feedback(data)
      @material = set_material(data)
      resprocessing = data.children.at("resprocessing")
      @max_score = set_max_score(resprocessing)
    end

    def set_correct_feedback(data)
      correct_feedback = data.children.css("itemfeedback[ident=correct]").first
      if correct_feedback && correct_feedback.search("mat_formattedtext")
        correct_feedback.search("mat_formattedtext").text
      else
        ""
      end
    end

    def set_incorrect_feedback(data)
      incorrect_feedback = data.children.
        css("itemfeedback[ident=incorrect]").first
      incorrect_children = incorrect_feedback.children.at("mat_formattedtext")
      if incorrect_feedback && incorrect_children
        incorrect_feedback.children.at("mat_formattedtext").text
      else
        ""
      end
    end

    def set_material(data)
      if (question_block = data.children.css("flow[@class=QUESTION_BLOCK]"))
        question_block.children.at("mat_formattedtext").text
      else
        ""
      end
    end

    def set_max_score(resprocessing)
      no_score = "0.0"
      outcomes = resprocessing.search("outcomes")
      if outcomes && !outcomes.search("decvar").empty?
        if outcomes.search("decvar")[0].attributes["maxvalue"]
          outcomes.search("decvar")[0].attributes["maxvalue"].value
        else
          no_score
        end
      else
        no_score
      end
    end
  end
end
