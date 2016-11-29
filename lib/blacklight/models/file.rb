require "blacklight/exceptions"
module Blacklight
  class BlacklightFile
    attr_accessor(:id, :location, :name)

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

    def self.cleanup
      # TODO add a cleanup method to delete course temp directory
    end
  end
end
