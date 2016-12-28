require "rake"
require "rake/clean"
require "senkyoshi"

## CHANGED THESE TO CHANGE THE FOLDER LOCATIONS
SOURCE_DIR = "sources".freeze
OUTPUT_DIR = "canvas".freeze
UPLOAD_DIR = "uploaded".freeze

## Don't change these, these are just getting the last
## of the folder name for the script below to use
SOURCE_NAME = SOURCE_DIR.split("/").last
OUTPUT_NAME = OUTPUT_DIR.split("/").last
UPLOAD_NAME = UPLOAD_DIR.split("/").last
SOURCE_FILES = Rake::FileList.new("#{SOURCE_DIR}/*.zip")
CONVERTED_FILES = Rake::FileList.new("#{OUTPUT_DIR}/*.imscc")

def source_for_imscc(imscc_file)
  SOURCE_FILES.detect do |f|
    path = imscc_file.pathmap("%{^#{OUTPUT_DIR}/,#{SOURCE_DIR}/}X")
    f.ext("") == path
  end
end

def source_for_upload_log(upload_log)
  CONVERTED_FILES.detect do |f|
    path = upload_log.pathmap("%{^#{UPLOAD_DIR}/,#{OUTPUT_DIR}/}X")
    f.ext("") == path
  end
end

def make_directories(name, upload_dir)
  mkdir_p name.pathmap("%d")
  mkdir_p upload_dir
end

def log_file(name)
  sh "touch #{name}"
  sh "date >> #{name}"
end

module Senkyoshi
  class Tasks
    extend Rake::DSL if defined? Rake::DSL

    ##
    # Creates rake tasks that can be ran from the gem.
    #
    # Add this to your Rakefile
    #
    #   require "senkyoshi/tasks"
    #   Senkyoshi::Tasks.install_tasks
    #
    ##
    def self.install_tasks
      namespace :senkyoshi do
        desc "Convert blackboard cartridges to canvas cartridges"
        task imscc: SOURCE_FILES.pathmap(
          "%{^#{SOURCE_NAME}/,#{OUTPUT_DIR}/}X.imscc",
        )

        directory OUTPUT_NAME

        rule ".imscc" => [->(f) { source_for_imscc(f) }, OUTPUT_NAME] do |t|
          make_directories(t.name, OUTPUT_DIR)
          Senkyoshi.parse(t.source, t.name)
        end

        desc "Upload converted files to canvas"
        task upload: CONVERTED_FILES.pathmap(
          "%{^#{OUTPUT_NAME}/,#{UPLOAD_DIR}/}X.txt",
        )

        directory UPLOAD_NAME

        rule ".txt" => [->(f) { source_for_upload_log(f) }, UPLOAD_NAME] do |t|
          make_directories(t.name, UPLOAD_DIR)
          Senkyoshi.initialize_course(t.source, source_for_imscc(t.source))
          log_file(t.name)
        end

        desc "Completely delete all converted files"
        task :clean do
          rm_rf OUTPUT_DIR
        end
      end
    end
  end
end
