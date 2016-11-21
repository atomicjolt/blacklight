require "blacklight/version"
require "blacklight/course"
require "blacklight/xml_parser"
require "blacklight/communication"
require "blacklight/api_groups"
require "optparse"
require "ostruct"
require "nokogiri"
require "zip"
require "pry"

require_relative "./blacklight/exceptions"

module Blacklight
  def self.parse(args)
    source_directory = validates_source_directory(args[0])
    output_directory = args[1]
    opens_dir(source_directory, output_directory)
  end

  def self.validates_source_directory(directory)
    if directory_exists?(directory)
      set_correct_dir_location(directory)
    else
      raise Exceptions::BadFileNameError
    end
  end

  def self.directory_exists?(dir_location)
    File.exists?(dir_location)
  end

  def self.set_correct_dir_location(dir_location)
    unless dir_location[dir_location.length - 1] == "/"
      dir_location = dir_location + "/"
    end
    dir_location
  end

  def self.opens_dir(source_folder, output_folder)
    Dir.glob(source_folder + "*.zip") do |zipfile|
      next if zipfile == "." || zipfile == ".."
      # do work on real items
      course = Course.new(zipfile)
      manifest = course.open_file("imsmanifest.xml")
      Blacklight.parse_manifest(manifest, course)
      course.output_to_dir(output_folder)
    end
  end
end
