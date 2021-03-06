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

include Senkyoshi

describe Senkyoshi do
  describe "Assessment" do
    before do
      @assessment = Assessment.new
      @resources = Senkyoshi::Collection.new
      @assignment_group_id = "fake_assn_id_123"
    end

    describe "initialize" do
      it "should initialize assessment" do
        assert_equal (@assessment.is_a? Senkyoshi::Assessment), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)

        title = "Just a test"
        points_possible = "120.0"
        group_name = "Test"
        quiz_type = "assignment"
        description = "<p>Do this test with honor</p>"
        instructions = "<p>Don't forget your virtue</p>"

        assert_equal (@assessment.instance_variable_get :@title), title
        assert_equal (@assessment.instance_variable_get :@quiz_type), quiz_type
        assert_equal (@assessment.
          instance_variable_get :@points_possible), points_possible
        assert_equal (@assessment.
          instance_variable_get :@group_name), group_name
        assert_equal (@assessment.instance_variable_get :@items).count, 12

        actual_description = @assessment.instance_variable_get :@description
        assert_includes actual_description, description
        assert_includes actual_description, instructions
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas assessment" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)

        course = CanvasCc::CanvasCC::Models::Course.new
        @assessment.canvas_conversion(course, @resources)
        assert_equal course.assessments.count, 1
      end
    end

    describe "setup_assessment" do
      it "should return assessment with details" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        title = "Just a test"
        description = "<p>Do this test with honor</p>"
        instructions = "<p>Don't forget your virtue</p>"

        assignment = @assessment.create_assignment(@assignment_group_id)
        assessment =
          @assessment.setup_assessment(assessment, assignment, @resources)
        assert_equal assessment.title, title
        assert_includes assessment.description, description
        assert_includes assessment.description, instructions
      end
    end

    describe "create_items" do
      it "should create items" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)
        course = CanvasCc::CanvasCC::Models::Course.new
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        assessment = @assessment.create_items(course, assessment, @resources)
        assert_equal assessment.items.count, 12
      end
    end

    describe "create_assignment_group" do
      it "should create assignment groups in course" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)

        result = AssignmentGroup.create_assignment_group(@assignment_group_id)
        assert_equal result.class, CanvasCc::CanvasCC::Models::AssignmentGroup
      end
    end

    describe "create_assignment" do
      it "should create an assignment" do
        xml = get_fixture_xml "assessment.xml"
        pre_data = {}
        quiz_type = "assignment"
        @assessment = @assessment.iterate_xml(xml.children.first, pre_data)

        assignment = @assessment.create_assignment(@assignment_group_id)
        assert_equal assignment.title,
                     (@assessment.instance_variable_get :@title)
        assert_equal (@assessment.instance_variable_get :@quiz_type), quiz_type
        assert_equal assignment.workflow_state,
                     (@assessment.instance_variable_get :@workflow_state)
        assert_equal assignment.points_possible,
                     (@assessment.instance_variable_get :@points_possible)
        assert_equal assignment.position, 1
        assert_equal assignment.grading_type, "points"
        assert_equal assignment.submission_types, ["online_quiz"]
      end
    end
  end
end
