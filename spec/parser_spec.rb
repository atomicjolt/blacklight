require "minitest/autorun"
require "blacklight"
require 'pry'

include Blacklight

describe Blacklight do

	describe "#pull_dir_location" do
		it "returns an exception" do
			args = ''
			err = assert_raises(Exception) { Blacklight.pull_dir_location(args) }
			assert_match /Bad File Name/, err.message
		end

		it "returns the filename string" do
			pathname = '/path/to/dir'
			args = Array.new
			args.push(pathname)
			assert_equal Blacklight.pull_dir_location(args), pathname
		end
	end

	describe "#directory_exists?" do
		it "should not exist" do
			pathname = '/path/to/dir'
			assert_equal Blacklight.directory_exists?(pathname), false
		end

		it "should exist" do
			pathname = 'spec'
			assert_equal Blacklight.directory_exists?(pathname), true
		end
	end

	describe "#set_correct_dir_location" do
		it "should return file ending in /" do
			pathname = '/path/to/dir'
			assert_equal Blacklight.set_correct_dir_location(pathname), pathname+'/'
		end

		it "should return file ending in /" do
			pathname = '/path/to/dir/'
			assert_equal Blacklight.set_correct_dir_location(pathname), pathname
		end
	end

	describe "#opens_dir" do
		it "should not exist" do
			pathname = '/path/to/dir/'
			assert_equal Blacklight.opens_dir(pathname), nil
		end

		it "should iterate through" do
		end
	end

end