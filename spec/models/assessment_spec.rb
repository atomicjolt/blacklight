require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "Assessment" do
    before do
      @assessment = Assessment.new
    end

    describe "initialize" do
      it "should initialize assessment" do
        assert_equal (@assessment.is_a? Object), true
      end
    end

    describe "iterate_xml" do
      it "should iterate through xml" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)

        points_possible = "120.0"
        title = "Just a test"
        description = "<p>Do this test with honor</p>"
        group_name = "Test"

        assert_equal (@assessment.instance_variable_get :@title), title
        assert_equal (@assessment.
          instance_variable_get :@points_possible), points_possible
        assert_equal (@assessment.
          instance_variable_get :@description), description
        assert_equal (@assessment.
          instance_variable_get :@group_name), group_name
        assert_equal (@assessment.instance_variable_get :@items).count, 12
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas assessment" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)

        course = CanvasCc::CanvasCC::Models::Course.new
        @assessment.canvas_conversion(course)
        assert_equal course.assessments.count, 1
      end
    end

    describe "setup_assessment" do
      it "should return assessment with details" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        title = "Just a test"
        description = "<p>Do this test with honor</p>"

        assignment = @assessment.create_assignment
        assessment = @assessment.setup_assessment(assessment, assignment)
        assert_equal assessment.title, title
        assert_equal assessment.description, description
      end
    end

    describe "create_items" do
      it "should create an items" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)
        assessment = CanvasCc::CanvasCC::Models::Assessment.new

        assessment = @assessment.create_items(assessment)
        assert_equal assessment.items.count, 12
      end
    end

    describe "create_assignment_group" do
      it "should create assignment groups in course" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)
        course = CanvasCc::CanvasCC::Models::Course.new

        course = @assessment.create_assignment_group(course)
        assert_equal course.assignment_groups.count, 1
      end
    end

    describe "create_assignment" do
      it "should create an assignment" do
        xml = get_fixture_xml "assessment.xml"
        @assessment = @assessment.iterate_xml(xml.children.first)

        assignment = @assessment.create_assignment
        assert_equal assignment.title,
                     (@assessment.instance_variable_get :@title)
        assert_equal assignment.assignment_group_identifier_ref,
                     (@assessment.instance_variable_get :@group_id)
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
