require "minitest/autorun"
require "blacklight"
require "pry"

include Blacklight

describe Blacklight do
  describe "Course" do
    before do
      @course = Course.new
    end

    describe "initialize" do
      it "should initialize course" do
        assert_equal (@course.is_a? Object), true
      end

      it "should create a canvas course" do
        identifier = @course.instance_variable_get :@identifier
        assert_equal (identifier.is_a? Object), true
      end
    end
  end
end
