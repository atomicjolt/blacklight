require "blacklight/version"
require "blacklight/xml_parser"
require "blacklight/canvas_course"

require "canvas_cc"
require "optparse"
require "ostruct"
require "nokogiri"
require "zip"

require_relative "./blacklight/exceptions"

module Blacklight
  def self.parse(source, output)
    source_directory = validates_source_directory(source)
    output_directory = output
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
    Dir.glob(source_folder + "*.zip") do |zip_path|
      next if zip_path == "." || zip_path == ".."
      # do work on real items
      zip_name = zip_path.split("/").last.gsub(".zip", "")
      zip_file = Zip::File.open(zip_path)
      manifest = open_file(zip_file, "imsmanifest.xml")

      resources = Blacklight.parse_manifest(zip_file, manifest)
      resources.concat(Blacklight.get_files(zip_file))
      # resources.concat(Blacklight.add_scorm(zip_file)) # TODO in canvas course

      course = create_canvas_course(resources, zip_name)
      output_to_dir(course, output_folder, zip_name)
    end
  end

  def self.open_file(zip_file, file_name)
    puts "Opening #{file_name}"
    begin
      zip_file.find_entry(file_name).get_input_stream.read
    rescue NoMethodError
      raise Exceptions::MissingFileError
    end
  end

  def self.output_to_dir(course, folder, zip_name)
    out_dir = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(folder)
    original_name = switch_file_name(out_dir, zip_name)
    cleanup
    puts "Created a file in #{original_name}"
  end

  def self.switch_file_name(canvas_name, zip_name)
    name = canvas_name.split("/").last.gsub(".imscc", "")
    original_name = canvas_name.gsub(name, zip_name)
    File.rename(canvas_name, original_name)
    original_name
  end

  ##
  # Perform any necessary cleanup from creating canvas cartridge
  ##
  def self.cleanup
    BlacklightFile.cleanup
    ScormPackage.cleanup
  end

  def self.create_canvas_course(resources, zip_name)
    course = CanvasCc::CanvasCC::Models::Course.new
    course.course_code = zip_name
    resources.each do |resource|
      course = resource.canvas_conversion(course)
    end
    course
  end

  def self.initialize_course(canvas_import, blackboard_export)
    metadata = Blacklight::CanvasCourse.metadata_from_file(canvas_import)
    bb_zip = Zip::File.new(blackboard_export) unless blackboard_export.nil?
    course = Blacklight::CanvasCourse.from_metadata(metadata, bb_zip)
    course.upload_content(canvas_import)
  end
end
