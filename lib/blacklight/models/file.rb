require "blacklight/exceptions"
module Blacklight
  class BlacklightFile
    attr_accessor(:id, :location, :name)

    # def iterate_xml(xml)
      # @title = xml.xpath("/CONTENT/TITLE/@value").first.text
      # @body = xml.xpath("/CONTENT/BODY/TEXT").first.text
      # @id = xml.xpath("/CONTENT/@id").first.text
      # @files = []
    # end

    def initialize(path)
      name = File.basename(path)
      id = name.scan(/__(xid-[0-9]+)/).first
      throw Exceptions::BadFileNameError.new unless id && id.size == 1

      @location = path # Location of file on local filesystem
      @name = name
      @id = id.first
    end

    def canvas_conversion
    end
  end
end
