require "rake/clean"
require "blacklight"
require "byebug"

## CHANGED THESE TO CHANGE THE FOLDER LOCATIONS
SOURCE_DIR = "sources".freeze
OUTPUT_DIR = "canvas".freeze

## Don"t change these, these are just getting the last
## of the folder name for the script below"s use
SOURCE_NAME = SOURCE_DIR.split("/").last
OUTPUT_NAME = OUTPUT_DIR.split("/").last
SOURCE_FILES = Rake::FileList.new("#{SOURCE_DIR}/*.zip")

def source_for_imscc(imscc_file)
  SOURCE_FILES.detect do |f|
    path = imscc_file.pathmap("%{^#{OUTPUT_DIR}/,#{SOURCE_DIR}/}X")
    f.ext("") == path
  end
end

module Blacklight
  class Tasks
    extend Rake::DSL if defined? Rake::DSL

    ##
    # Creates rake tasks that can be ran from the gem.
    #
    # Add this to your Rakefile
    #
    #   require "blacklight/tasks"
    #   Blacklight::Tasks.install_tasks
    #
    ##
    def self.install_tasks
      namespace :blacklight do
        desc "Convert blackboard cartridges to canvas cartridges"
        task imscc: SOURCE_FILES.pathmap(
          "%{^#{SOURCE_NAME}/,#{OUTPUT_DIR}/}X.imscc",
        )

        directory OUTPUT_NAME

        rule ".imscc" => [->(f) { source_for_imscc(f) }, OUTPUT_NAME] do |t|
          mkdir_p t.name.pathmap("%d")
          mkdir_p OUTPUT_DIR
          Blacklight.parse(SOURCE_DIR, OUTPUT_DIR)
        end

        desc "Completely delete all converted files"
        task :clean do
          rm_rf OUTPUT_DIR
        end
      end
    end
  end
end
