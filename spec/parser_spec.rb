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

	describe "#opens_dir" do

	end

end