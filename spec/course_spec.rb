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

		describe "#open_file" do
			it "should return with an error" do
				err = assert_raises(Exception) { @course.open_file("") }
				assert_match /Couldn't find file/, err.message
			end
		end
	end

	describe "#create_canvas_cc_course" do
		it "should return with a course" do
			course = Blacklight.create_canvas_cc_course
			is_object = course.is_a? Object
			assert_equal is_object, true
		end
	end

end