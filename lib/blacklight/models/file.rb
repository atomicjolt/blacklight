require "blacklight/models/resource"
require "blacklight/exceptions"

module Blacklight
  class BlacklightFile < Resource
    attr_accessor(:id, :location, :name)

    def initialize(zip_entry)
      path = zip_entry.name
      id = File.basename(path)
      xid = id[/__(xid-[0-9]+_[0-9]+)/, 1]
      name = id.gsub(/__xid-[0-9]+_[0-9]+/, "")

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

    def canvas_conversion(course, _resources)
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
  end
end
