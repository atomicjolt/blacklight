require "senkyoshi/version"
require "senkyoshi/xml_parser"
require "senkyoshi/canvas_course"
require "senkyoshi/collection"

require "canvas_cc"
require "optparse"
require "ostruct"
require "nokogiri"
require "zip"

require "senkyoshi/exceptions"

module Senkyoshi
  IMPORTED_FILES_DIRNAME = "Imported".freeze
  BASE = "$IMS-CC-FILEBASE$".freeze

  def self.parse(zip_path, imscc_path)
    Zip::File.open(zip_path) do |file|
      manifest = read_file(file, "imsmanifest.xml")

      resources = Senkyoshi::Collection.new
      resources.add(Senkyoshi.iterate_files(file))
      resource_xids = resources.resources.
        map(&:xid).
        select { |r| r.include?("xid-") }
      resources.add(Senkyoshi.parse_manifest(file, manifest, resource_xids))

      course = create_canvas_course(resources, zip_path)
      build_file(course, imscc_path)
    end
  end

  def self.read_file(zip_file, file_name)
    zip_file.find_entry(file_name).get_input_stream.read
  rescue NoMethodError
    raise Exceptions::MissingFileError
  end

  def self.build_file(course, imscc_path)
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
    SenkyoshiFile.cleanup
    ScormPackage.cleanup
  end

  def self.create_canvas_course(resources, zip_name)
    course = CanvasCc::CanvasCC::Models::Course.new
    course.course_code = zip_name
    resources.each do |resource|
      course = resource.canvas_conversion(course, resources)
    end
    course
  end

  def self.initialize_course(canvas_file_path, blackboard_file_path)
    metadata = Senkyoshi::CanvasCourse.metadata_from_file(canvas_file_path)
    Zip::File.open(blackboard_file_path, "rb") do |bb_zip|
      course = Senkyoshi::CanvasCourse.from_metadata(metadata, bb_zip)
      course.upload_content(canvas_file_path)
    end
  end

  def true?(obj)
    obj.to_s == "true"
  end
end
