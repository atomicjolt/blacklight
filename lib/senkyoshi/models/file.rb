require "senkyoshi/models/resource"
require "senkyoshi/exceptions"

module Senkyoshi
  class SenkyoshiFile < Resource
    attr_accessor(:id, :location, :name)
    @@dir = nil

    FILE_BLACKLIST = [
      "*.dat",
    ].freeze

    def initialize(zip_entry)
      path = zip_entry.name
      # byebug
      id = File.basename(path)

      xid = id[/__(xid-[0-9]+_[0-9]+)/, 1]
      name = id.gsub(/__xid-[0-9]+_[0-9]+/, "")
      id = name

      @location = extract_file(zip_entry) # Location of file on local filesystem
      @name = name
      @id = id
      @xid = xid
    end

    def matches_xid?(xid)
      @xid == xid
    end

    def extract_file(entry)
      @@dir ||= Dir.mktmpdir

      name = "#{@@dir}/#{entry.name}"
      path = File.dirname(name)
      FileUtils.mkdir_p path unless Dir.exist? path
      entry.extract(name)
      name
    end

    def canvas_conversion(course, _resources = nil)
      file = CanvasCc::CanvasCC::Models::CanvasFile.new
      file.identifier = @id
      file.file_location = @location
      file.file_path = "#{IMPORTED_FILES_DIRNAME}/#{@name}"
      file.hidden = false

      course.files << file
      course
    end

    ##
    # Remove temporary files
    ##
    def self.cleanup
      FileUtils.rm_r @@dir unless @@dir.nil?
    end

    ##
    # Determine if a file is on the blacklist
    ##
    def self.blacklisted?(file)
      FILE_BLACKLIST.any? { |list_item| File.fnmatch?(list_item, file.name) }
    end

    ##
    # Determine whether or not a file is a metadata file or not
    ##
    def self.metadata_file?(file_names, file)
      if File.extname(file.name) == ".xml"
        # Detect and skip metadata files.
        concrete_file = File.join(
          File.dirname(file.name),
          File.basename(file.name, ".xml"),
        )
        file_names.include?(concrete_file)
      else
        false
      end
    end

    ##
    # Determine whether or not a file is a part of a scorm package
    ##
    def self.belongs_to_scorm_package?(package_paths, file)
      package_paths.any? do |path|
        File.dirname(file.name).start_with? path
      end
    end

    ##
    # Determine if a file should be included in course files or not
    ##
    def self.valid_file?(file_names, scorm_paths, file)
      return false if SenkyoshiFile.blacklisted? file
      return false if SenkyoshiFile.metadata_file? file_names, file
      return false if SenkyoshiFile.belongs_to_scorm_package? scorm_paths, file
      true
    end
  end
end
