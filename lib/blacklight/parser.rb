require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'pry'
require 'zip'

require_relative 'exceptions'

module Blacklight

  def self.parse(args)
  	source_directory = validates_source_directory(args[0])
  	output_directory = args[1]
  	announcement_directory = args[2]
  	opens_dir(source_directory, output_directory, announcement_directory)
  end

  def self.validates_source_directory(directory)
		if directory_exists?(directory)
			dir_location = set_correct_dir_location(directory)
		else
			raise Exceptions::BadFileNameError
		end
  end

  def self.directory_exists?(dir_location)
  	File.exists?(dir_location)
  end

  def self.set_correct_dir_location(dir_location)
  	dir_location = dir_location + '/' unless dir_location[dir_location.length-1] == '/'
  	dir_location
  end

  def self.opens_dir(source_folder, output_folder, announcement_directory)
  	Dir.glob(source_folder +'*.zip') do |zipfile|
  		next if zipfile == '.' or zipfile == '..'
  		# do work on real items
  		course = Course.new(zipfile)
  		FileUtils.rm_rf(announcement_directory)
  		FileUtils.mkdir(announcement_directory)
  		manifest = course.open_file("imsmanifest.xml")
  		Blacklight.parse_manifest(manifest, course)
  		course.output_to_dir(output_folder, announcement_directory)
  	end
  	FileUtils.rm_rf(announcement_directory)
  end



end
