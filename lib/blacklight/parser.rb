require 'optparse'
require 'ostruct'
require 'pry'
require_relative 'exceptions'

module Blacklight

  def self.parse(args)
  	dir_location = pull_dir_location(args)
  	if directory_exists?(dir_location)
  		opens_dir(dir_location)
  	else
  		raise Exceptions::BadFileNameError
  	end
  end

  def self.pull_dir_location(args)
  	begin
  		dir_location = args.shift
  	rescue
 			raise Exceptions::BadFileNameError
 		end
 		dir_location
  end

  def self.directory_exists?(dir_location)
  	File.exists?(dir_location)
  end

  def self.opens_dir(file)

  end

end
