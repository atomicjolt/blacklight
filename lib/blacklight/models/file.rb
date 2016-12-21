require "blacklight/exceptions"
module Blacklight
  class BlacklightFile
    attr_accessor(:id, :location, :name)
    @@dir = nil

    FILE_BLACKLIST = [
      "*.dat",
    ].freeze

    def initialize(zip_entry)
      path = zip_entry.name
      id = File.basename(path)
      name = id.gsub(/__xid-[0-9]+_[0-9]+/, "")

      @location = extract_file(zip_entry) # Location of file on local filesystem
      @name = name
      @id = id
    end

    def extract_file(entry)
      @@dir ||= Dir.mktmpdir

      name = "#{@@dir}/#{entry.name}"
      path = File.dirname(name)
      FileUtils.mkdir_p path unless Dir.exist? path
      entry.extract(name)
      name
    end

    def canvas_conversion(course)
      file = CanvasCc::CanvasCC::Models::CanvasFile.new
      file.identifier = @id
      file.file_location = @location
      file.file_path = @name
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

    def self.blacklisted?(file)
      FILE_BLACKLIST.each do |list_item|
        return true if File.fnmatch?(list_item, file.name)
      end
      false
    end

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

    def self.belongs_to_scorm_package?(package_paths, file)
      package_paths.each do |path|
        return true if File.dirname(file.name).start_with? path
      end
      false
    end

    def self.valid_file?(file_names, file)
      return false if BlacklightFile.blacklisted? file
      return false if BlacklightFile.metadata_file? file_names, file
      true
    end
  end
end
