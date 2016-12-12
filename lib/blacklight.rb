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
  def self.parse(zip_path, imscc_path)
    Zip::File.open(zip_path) do |file|
      manifest = open_file(file, "imsmanifest.xml")

      resources = Blacklight.parse_manifest(file, manifest)
      resources.concat(Blacklight.iterate_files(file))

      course = create_canvas_course(resources, zip_path)
      output_to_dir(course, imscc_path)
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

  def self.output_to_dir(course, imscc_path)
    folder = imscc_path.split("/").first
    file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(folder)
    File.rename(file, imscc_path)
    cleanup
    puts "Created a file #{imscc_path}"
  end

  ##
  # Perform any necessary cleanup from creating canvas cartridge
  ##
  def self.cleanup
    BlacklightFile.cleanup
  end

  def self.create_canvas_course(resources, zip_name)
    course = CanvasCc::CanvasCC::Models::Course.new
    course.course_code = zip_name
    resources.each do |resource|
      course = resource.canvas_conversion(course)
    end
    course
  end

  def self.initialize_course(filename)
    metadata = Blacklight::CanvasCourse.metadata_from_file(filename)
    course = Blacklight::CanvasCourse.from_metadata(metadata)
    course.upload_content(filename)
  end
end
