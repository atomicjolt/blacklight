require "blacklight/models/resource"

module Blacklight
  class Question < Resource
    attr_reader :answers

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
      "Calculated" => "calculated_question",
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
      "Numeric" => "NumericalQuestion",
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
      type = item.at("bbmd_questiontype").children.text
      item_class = Blacklight.const_get ITEM_FUNCTION[type]
      question = item_class.new
      question.iterate_xml(item)
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
      @original_identifier = data.at("bbmd_asi_object_id").text
      @blackboard_type = data.at("bbmd_questiontype").text
      @question_type = QUESTION_TYPE[@blackboard_type]
      @question = CanvasCc::CanvasCC::Models::Question.create(@question_type)
      @points_possible = data.at("qmd_absolutescore_max").text
      title = data.attributes["title"]
      @title = title ? title.value : ""
      iterate_item(data)
      self
    end

    def canvas_conversion(assessment, resources)
      @question.identifier = Blacklight.create_random_hex
      @question.title = @title
      @question.points_possible = @points_possible
      @question.material = fix_images(@material, resources)
      @question.general_feedback = fix_images(@general_feedback, resources)
      @general_correct_feedback =
        fix_images(@general_correct_feedback, resources)
      @question.general_correct_feedback = @general_correct_feedback
      @general_incorrect_feedback =
        fix_images(@general_incorrect_feedback, resources)
      @question.general_incorrect_feedback = @general_incorrect_feedback
      @question.answers = []
      @answers.each do |answer|
        @question = answer.canvas_conversion(@question, resources)
      end
      assessment.items << @question
      assessment
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
      correct = resprocessing.at("respcondition[title=correct]")
      if correct
        if correct.at("varequal")
          @correct_answers["name"] = correct.at("varequal").text
        end
        score = correct.at("setvar") ? correct.at("setvar").text : 0
        score_number = score == "SCORE.max" ? @max_score.to_f : score.to_f
        if score_number > 0
          @correct_answers["fraction"] = score_number.to_f / @max_score.to_f
        else
          @correct_answers["fraction"] = 0
        end
      end
    end

    def set_incorrect_answers(resprocessing)
      incorrect = resprocessing.at("respcondition[title=incorrect]")
      if incorrect
        if incorrect.at("varequal")
          @incorrect_answers["name"] = incorrect.at("varequal").text
        end
        score = incorrect.at("setvar") ? incorrect.at("setvar").text : 0
        score_number = score == "SCORE.max" ? @max_score.to_f : score.to_f
        if score_number > 0
          @incorrect_answers["fraction"] = score_number.to_f / @max_score.to_f
        else
          @incorrect_answers["fraction"] = 0
        end
      end
    end

    def iterate_item(data)
      @general_correct_feedback = set_feedback(data, "correct")
      @general_incorrect_feedback = set_feedback(data, "incorrect")
      @material = set_material(data)
      resprocessing = data.at("resprocessing")
      @max_score = set_max_score(resprocessing)
    end

    def set_feedback(data, type)
      feedback = data.at("itemfeedback[ident=#{type}]")
      if feedback && feedback.at("mat_formattedtext")
        feedback.at("mat_formattedtext").text
      else
        ""
      end
    end

    def set_material(data)
      if (question_block = data.at("flow[@class=QUESTION_BLOCK]"))
        question_block.at("mat_formattedtext").text
      else
        ""
      end
    end

    def set_max_score(resprocessing)
      no_score = "0.0"
      outcomes = resprocessing.at("outcomes")
      if outcomes && !outcomes.at("decvar").nil?
        if outcomes.at("decvar").attributes["maxvalue"]
          outcomes.at("decvar").attributes["maxvalue"].value
        else
          no_score
        end
      else
        no_score
      end
    end
  end
end
