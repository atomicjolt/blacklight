require "blacklight/exceptions"
module Blacklight
  class BlacklightFile
    attr_accessor(:id, :location, :name)

    def initialize(zip_entry)
      path = zip_entry.name
      name = File.basename(path)
      id = name.scan(/__(xid-[0-9]+)/).first
      throw Exceptions::BadFileNameError.new unless id && id.size == 1

      @location = path # Location of file on local filesystem
      @name = name
      @id = id.first
    end

    # def extract_file(entry)
      # @@dir ||= Dir.mktmpdir

      # FileUtils.mkdir_p (dir+'/csfiles/home_dir/')
      # Dir.exist?(dir+'/csfiles/home_dir/')
        # name = "#{@@dir}/#{e.name}"
        # path = File.dirname(name)
        #
        # FileUtils.mkdir_p (path) unless Dir.exist? path
        # e.extract(name)
      # end

    def canvas_conversion(course)
      file = CanvasCc::CanvasCC::Models::CanvasFile.new
      file.identifier = @id
      file.file_location = @location
      file.file_path = @name
      file.hidden = false

      course.files << file
      course
    end

    # TODO add a cleanup method to delete course temp directory
  end
end
