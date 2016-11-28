require "blacklight/exceptions"
module Blacklight
  class BlacklightFile
    attr_accessor(:id, :location, :name)

    def initialize(path)
      name = File.basename(path)
      id = name.scan(/__(xid-[0-9]+)/).first
      throw Exceptions::BadFileNameError.new unless id && id.size == 1

      @location = path # Location of file on local filesystem
      @name = name
      @id = id.first
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
  end
end
