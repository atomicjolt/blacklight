require "senkyoshi/models/qti"
require "byebug"

module Senkyoshi
  class QuestionBank < QTI
    def canvas_conversion(course, resources)
      question_bank = CanvasCc::CanvasCC::Models::QuestionBank.new
      question_bank.identifier = @id
      question_bank.title = @title
      question_bank = setup_question_bank(question_bank, resources)
      course.question_banks << question_bank
      course
    end

    def setup_question_bank(question_bank, resources)
      if @items.count.zero?
        question_bank.description +=
          "Empty Quiz -- No questions were contained in the blackboard quiz bank"
      end
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
        question_bank.questions << question
      end
      question_bank
    end
  end
end
