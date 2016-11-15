require "minitest/autorun"
require "blacklight"
require 'pry'

include Blacklight

describe Blacklight do

	describe "Course" do
		before do
			@file_path = File.expand_path('../fixtures/', __FILE__) + '/test.zip'
			file = Minitest::Mock.new
			Zip::File.stub :open, file do
		    @course = Course.new(@file_path)
		  end
		end

		describe "#initialize" do
			it "should initialize course" do
		    assert_equal (@course.is_a? Object), true
			end
		end

		describe "#create_canvas_cc_course" do
			it "should return with a course" do
				canvas_course = @course.instance_variable_get :@canvas_course
				assert_equal (canvas_course.is_a? Object), true
			end
		end

		describe "#open_file" do
			it "should return with an error" do
				err = assert_raises(Exception) { @course.open_file("") }
				assert_match /Couldn't find file/, err.message
			end
		end

		describe "#set_course_values" do
			it "should set the canvas course values" do
				name = "identification"
				value = 'RandomID23joirjeowijafoi'
				@course.set_course_values(name, value)
				canvas_course = @course.instance_variable_get :@canvas_course
				assert_equal canvas_course.send(name.to_sym), value
			end

			it "should not override previous settings" do
				name = "identification"
				value = 'RandomID23joirjeowijafoi'
				@course.set_course_values(name, value)
				name2 = "title"
				value2 = 'The Randomest Course'
				@course.set_course_values(name2, value2)
				canvas_course = @course.instance_variable_get :@canvas_course
				assert_equal canvas_course.send(name.to_sym), value
				assert_equal canvas_course.send(name2.to_sym), value2
			end
		end

	end

end