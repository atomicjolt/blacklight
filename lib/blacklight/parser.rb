# frozen_string_literal: true
require "optparse"
require "ostruct"
require "nokogiri"
require "pry"
require "zip"

require_relative "exceptions"

module Blacklight

  def self.parse(args)
    source_directory = validates_source_directory(args[0])
    output_directory = args[1]
    opens_dir(source_directory, output_directory)
  end

  def self.validates_source_directory(directory)
    begin
      dir_location = set_correct_dir_location(directory)
    rescue
     raise Exceptions::BadFileNameError
    end
  end

  def self.directory_exists?(dir_location)
    File.exists?(dir_location)
  end

  def self.set_correct_dir_location(dir_location)
    dir_location = dir_location + "/" unless dir_location[dir_location.length-1] == "/"
    dir_location
  end

  def self.opens_dir(source_folder, output_folder)
    Dir.glob(source_folder +"*.zip") do |zipfile|
     next if zipfile == "." or zipfile == ".."
     # do work on real items
     course = Course.new(zipfile)
     manifest = course.open_file("imsmanifest.xml")
     Blacklight.parse_manifest(manifest, course)
     course.output_to_dir(output_folder)
    end
  end



end
