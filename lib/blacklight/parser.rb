require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'pry'
require 'zip'

require_relative 'exceptions'

module Blacklight

  def self.parse(args)
  	dir_location = pull_dir_location(args)
  	if directory_exists?(dir_location)
  		dir_location = set_correct_dir_location(dir_location)
  		opens_dir(dir_location)
  	else
  		raise Exceptions::BadFileNameError
  	end
  end

  def self.pull_dir_location(args)
  	begin
  		dir_location = args.shift
  	rescue
 			raise Exceptions::BadFileNameError
 		end
 		dir_location
  end

  def self.directory_exists?(dir_location)
  	File.exists?(dir_location)
  end

  def self.set_correct_dir_location(dir_location)
  	dir_location = dir_location + '/' unless dir_location[dir_location.length-1] == '/'
  	dir_location
  end

  def self.opens_dir(dir_location)
  	Dir.glob(dir_location +'*.zip') do |zipfile|
  		next if zipfile == '.' or zipfile == '..'
  		# do work on real items
  		course = Course.new(zipfile)
  		manifest = course.open_file("imsmanifest.xml")
  		Blacklight.parse_manifest(manifest, course)
  	end
  end



end
