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
