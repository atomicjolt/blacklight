require "minitest/autorun"
require "senkyoshi"
require "pry"

include Senkyoshi

describe Senkyoshi do
  describe "AssignmentGroup" do
    before do
      @title = "Group Title"
      @group_id = SecureRandom.hex
      @assignment_group = AssignmentGroup.new(@title, @group_id)
    end

    describe "initialize" do
      it "should initialize assignment_group" do
        assert_equal (@assignment_group.is_a? Object), true
      end

      it "should initialize with parameters" do
        assert_equal (@assignment_group.instance_variable_get :@title), @title
        assert_equal (@assignment_group.
          instance_variable_get :@id), @group_id
      end
    end

    describe "canvas_conversion" do
      it "should create a canvas assignment_group" do
        course = CanvasCc::CanvasCC::Models::Course.new
        @assignment_group.canvas_conversion(course)
        assert_equal course.assignment_groups.count, 1
      end

      it "should create a canvas assignment_group with correct details" do
        course = CanvasCc::CanvasCC::Models::Course.new
        @assignment_group.canvas_conversion(course)
        assert_equal course.assignment_groups.first.title, @title
        assert_equal course.assignment_groups.first.identifier, @group_id
      end
    end
  end
end
