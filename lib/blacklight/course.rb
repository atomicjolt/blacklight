require 'canvas_cc'
require 'fileutils'
require_relative 'exceptions'


module Blacklight

	class Course
 	  ##
	  # This class represents a reader for one zip file, and allows the usage of
	  # individual files within zip file
	  ##
    def initialize(zip_path)
    	@name = zip_path.split('/').last.gsub('.zip', '')
    	@zip_file = Zip::File.open(zip_path)
    	@canvas_course = CanvasCc::CanvasCC::Models::Course.new
    	@values = {}
    	set_course_values('course_code', @name)
    end

    def open_file(file_name)
    	puts "Opening #{file_name}"
	  	begin
	      @zip_file.find_entry(file_name).get_input_stream.read
	    rescue NoMethodError
	    	raise Exceptions::MissingFileError
	    end
	  end

	  def add_to_values(name, values)
	  	@values[name] = {} unless @values[name]
	  	@values[name] = @values[name].merge(values)
	  end

	  def set_course_values(name, value)
	  	@canvas_course.send(name+'=', value)
	  end

	  def add_announcement(announcement)
	  	@canvas_course.announcements << announcement
	  end

	  def output_to_dir(output_folder, announcement_directory)
	    output_dir = CanvasCc::CanvasCC::CartridgeCreator.new(@canvas_course).create(output_folder)
	    output_dir = add_announcements_to_zip(output_dir, announcement_directory)
	    original_name = switch_file_name(output_dir)
	    puts "Created a file in #{original_name}"
		end

		def add_announcements_to_zip(output_dir, announcement_directory)
			entries = Dir.entries(announcement_directory) - %w(. ..)
			Zip::File.open(output_dir, Zip::File::CREATE) do |zip_file|
			  entries.each do |filename|
			    zip_file.add(filename, announcement_directory + '/' + filename)
			  end
			end
			output_dir
		end

		def switch_file_name(canvas_name)
			name = canvas_name.split('/').last.gsub('.imscc', '')
			original_name = canvas_name.gsub(name, @name)
			File.rename(canvas_name, original_name)
			original_name
		end

  end

end
