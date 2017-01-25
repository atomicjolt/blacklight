require "minitest/autorun"

require "senkyoshi"
require "pry"

require_relative "../helpers.rb"
require_relative "../mocks/canvas_cc_factory"

describe "GradeCompletedCriteria" do
  describe "canvas_conversion" do
    before(:each) do
      @course = make_fake_course_with_single_module

      @outcome_def_id = "outcome1"
      @foreign_content_id = @course.canvas_modules.first.
        module_items.last.identifier
      @content_id = @course.canvas_modules.first.module_items.first.identifier
      @outcome_def = OutcomeDefinition.new(
        nil, @outcome_def_id, @foreign_content_id
      )
      @resources = Collection.new([Gradebook.new("res009", [], [@outcome_def])])
      @id = "grade_completed_criteria"
      @subject = GradeCompletedCriteria.new(@id, @outcome_def_id, false)
    end

    it "should use assignment content id as foreign_content_id" do
      result = @subject.canvas_conversion(@course, @content_id, @resources)

      canvas_module = result.canvas_modules.first
      assert_equal(canvas_module.completion_requirements.size, 1)
      assert_equal(
        canvas_module.completion_requirements.first.identifierref,
        @foreign_content_id,
      )
    end
  end
end
