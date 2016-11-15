require 'canvas_cc'
require_relative 'exceptions'


module Blacklight

	class Course
		attr_accessor :zip_file
 	  ##
	  # This class represents a reader for one zip file, and allows the usage of
	  # individual files within zip file
	  ##
    def initialize(zip_path)
    	@path = zip_path
    	@zip_file = Zip::File.open(zip_path)
    	@values = {}
    end

    def open_file(file_name)
    	puts "Opening #{file_name}"
	  	begin
	      @zip_file.find_entry(file_name).get_input_stream.read
	    rescue NoMethodError
	    	raise Exceptions::MissingFileError
	    end
	  end

  end

	def self.create_canvas_cc_course
		CanvasCc::CanvasCC::Models::Course.new
	end

end
