# Copyright (C) 2016, 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "senkyoshi/version"
require "senkyoshi/xml_parser"
require "senkyoshi/models/module_converter"
require "senkyoshi/canvas_course"
require "senkyoshi/collection"
require "senkyoshi/configuration"

require "canvas_cc"
require "optparse"
require "ostruct"
require "nokogiri"
require "zip"
require "fileutils"

Zip.write_zip64_support = true

require "senkyoshi/exceptions"

module Senkyoshi
  FILE_BASE = "$IMS-CC-FILEBASE$".freeze
  DIR_BASE = "$CANVAS_COURSE_REFERENCE$/files/folder".freeze
  MAIN_CANVAS_MODULE = "aj_main_module".freeze
  MASTER_MODULE = "master_module".freeze

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.parse(zip_path, imscc_path)
    Zip::File.open(zip_path) do |file|
      manifest = read_file(file, "imsmanifest.xml")

      resources = Senkyoshi::Collection.new
      resources.add(Senkyoshi.iterate_files(file))
      resource_xids = resources.resources.
        map(&:xid).
        select { |r| r.include?("xid-") }

      xml = Nokogiri::XML.parse(manifest)
      xml_resources = xml.at("resources")
      xml_organizations = xml.at("organizations")

      pre_data = Senkyoshi.pre_iterator(xml_organizations, xml_resources, file)
      resources.add(
        Senkyoshi.iterate_xml(xml_resources, file, resource_xids, pre_data),
      )

      course = create_canvas_course(resources, zip_path, pre_data)
      build_file(course, imscc_path, resources)
    end
  end

  def self.parse_and_process_single(zip_path, imscc_path)
    Senkyoshi.parse(zip_path, imscc_path)
  end

  def self.read_file(zip_file, file_name)
    zip_file.find_entry(file_name).get_input_stream.read
  rescue NoMethodError
    raise Exceptions::MissingFileError
  end

  def self.build_file(course, imscc_path, resources)
    file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(Dir.tmpdir)
    FileUtils.mv(file, imscc_path, force: true)
    cleanup resources
    puts "Created a file #{imscc_path}"
  end

  ##
  # Perform any necessary cleanup from creating canvas cartridge
  ##
  def self.cleanup(resources)
    resources.each(&:cleanup)
  end

  def self.create_canvas_course(resources, zip_name, pre_data)
    course = CanvasCc::CanvasCC::Models::Course.new
    course.course_code = zip_name

    # Wait until after we set modules to convert Rules
    resources.find_instances_not_of([Rule]).each do |resource|
      course = resource.canvas_conversion(course, resources)
    end

    course = ModuleConverter.set_modules(course, pre_data)
    resources.find_instances_of(Rule).each do |rule|
      course = rule.canvas_conversion(course, resources)
    end

    course
  end

  def self.initialize_course(canvas_file_path, blackboard_file_path)
    metadata = Senkyoshi::CanvasCourse.metadata_from_file(canvas_file_path)
    Zip::File.open(blackboard_file_path, "rb") do |bb_zip|
      course = Senkyoshi::CanvasCourse.from_metadata(metadata, bb_zip)
      course.upload_content(canvas_file_path)
      cleanup course.scorm_packages
    end
  end

  def self.true?(obj)
    obj.to_s == "true"
  end
end
